"""
Usage:
  ebb [--config=FILE] init
  ebb [--config=FILE] update <gateway>
  ebb [--config=FILE] publish

Options:
  --config=FILE  Config file [default: ~/.ebb.rc]
  -h --help      Show this screen.
  --version      Show version.

"""
from docopt import docopt
from ebb import query, __version__


def main():
    args = docopt(__doc__, version=__version__)
    print(args)
    query.WinlinkQuery(args).main()


if __name__ == "__main__":
    main()
