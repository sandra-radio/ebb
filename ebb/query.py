from configparser import ConfigParser
import requests
import re
import sqlite3
from ebb import wave


def read_config_file(filename):
    cfg = ConfigParser()
    cfg.read(filename)
    try:
        options = dict(cfg["options"])
    except KeyError:
        options = {}
    return options


class WinlinkQuery:
    def __init__(self, config):
        self.config = config
        # TODO: merge config_file and config options
        self.token = read_config_file(config["--config"])["token"]
        self.db_path = read_config_file(config["--config"]).get("db_path", "ebb.sqlite")
        self._cached_conn = None

    def getConn(self):
        if self._cached_conn is None:
            self._cached_conn = sqlite3.connect(self.db_path)
        return self._cached_conn

    def initDB(self):
        self.getConn().cursor().execute(
            """CREATE TABLE IF NOT EXISTS traffic (
          gateway TEXT,
          messageId TEXT,
          timestamp INTEGER,
          site TEXT,
          event TEXT,
          clientType INTEGER,
          callsign TEXT,
          source TEXT,
          sender TEXT,
          subject TEXT,
          size INTEGER,
          attachments INTEGER,
          frequency INTEGER,
          PRIMARY KEY (gateway, messageId)
        )"""
        )

        self.getConn().cursor().execute(
            """CREATE VIEW IF NOT EXISTS v_status (
            health,
            gateway,
            total_messages,
            latest_message,
            oldest_message
        )
        AS
        SELECT ((unixepoch()-(MAX(timestamp)/1000)) > 86400) + ((unixepoch()-(MAX(timestamp)/1000)) > 172800) as health, gateway, count(*) as 'Total Messages',DATETIME((MAX(timestamp)/1000), 'unixepoch') as 'Latest Message', DATETIME((MIN(timestamp)/1000), 'unixepoch') as 'Oldest Message' from traffic GROUP BY gateway;
        """
        )

    def soloQuery(self, callsign):
        # TODO: investigate the differences between:
        #    "Event": "Accepted"
        #    "ClientType": 9
        #     "Timestamp": "/Date(1682811688000)/"
        # api ref: https://api.winlink.org/json/metadata?op=TrafficLogsCallsignGet
        # swagger: https://api.winlink.org/swagger-ui/#/

        # Works!
        query = {"Callsign": callsign, "Key": self.token}
        headers = {"Content-type": "application/json"}
        response = requests.get(
            "https://api.winlink.org/traffic/logs/callsign/get",
            params=query,
            headers=headers,
        )
        return response.json()

    def populateDBTraffic(self, entries):
        # Iterating through the json$$
        # list
        for entry in entries["TrafficList"]:
            # normalize the timestamp into unix time
            entry["Timestamp"] = re.search(r"\((.*?)\)", entry["Timestamp"]).group(1)
            try:
                sql = "INSERT OR IGNORE INTO traffic ({}) VALUES ({})".format(
                    ",".join(entry.keys()), ",".join(["?"] * len(entry.keys()))
                )
                self.getConn().cursor().execute(sql, tuple(entry.values()))
            except Exception as E:
                print("Error : ", E)
            else:
                self.getConn().commit()

    def main(self):
        if self.config["init"]:
            self.initDB()
        elif self.config["update"]:
            data = self.soloQuery(self.config["<gateway>"])
            print(data)
            self.populateDBTraffic(data)
        elif self.config["publish"]:
            wave.go(self.getConn())
