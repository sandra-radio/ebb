from h2o_wave import data, site, ui
from datetime import datetime

def go(conn):
    page = site['/']

    cursor = conn.cursor()
    # Get last week of entries
    #cursor.execute("select gateway, timestamp, 1 from traffic where timestamp/1000 > (strftime('%s','now') - 7 * 24 * 60 * 60);")
    cursor.execute("select gateway, strftime('%m-%d', timestamp / 1000, 'unixepoch') as day, count(*) as mail from traffic where timestamp/1000 > (strftime('%s','now') - 14 * 24 * 60 * 60) group by gateway, day order by day")
    mail_results = cursor.fetchall()


    page['example'] = ui.plot_card(
        box='1 1 8 8',
        title='Winlink Heatmap (Updated: {})'.format(datetime.now().astimezone().strftime("%m-%d-%YT%H:%M:%S %Z")),
        data=data('callsign day mail', len(mail_results), rows=mail_results),

        plot=ui.plot([ui.mark(type='polygon',
                              x='=day',
                              y="=callsign",
                              y_title='RMS',
                              color='=mail',
                              color_range='#fee8c8 #fdbb84 #e34a33')])
    )

    cursor.execute("select count(*) as mail from traffic where timestamp/1000 > (strftime('%s','now') - 14 * 24 * 60 * 60)")
    mail_results = cursor.fetchall()
    cursor.execute("select count(DISTINCT callsign) from traffic where timestamp/1000 > (strftime('%s','now') - 14 * 24 * 60 * 60)")
    callsigns = cursor.fetchall()
    cursor.execute("select count(DISTINCT gateway) from traffic where timestamp/1000 > (strftime('%s','now') - 14 * 24 * 60 * 60)")
    gateways = cursor.fetchall()
    page.add('example2', ui.tall_stats_card(
        box='9 1 2 4',
        items=[
            ui.stat(label='Gateways Tracked', value=str(gateways[0][0])),
            ui.stat(label='# of Callsigns', value=str(callsigns[0][0])),
            ui.stat(label='Messages', value=str(mail_results[0][0]))
        ]
    ))

    # Finally, save the page.
    page.save()
