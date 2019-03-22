from pygments.lexer import RegexLexer, bygroups
from pygments.token import *

class AlgLexer(RegexLexer):
    tokens = {
        'root': [
            (r'(?i)([\w\-]+)(\()', bygroups(Name.Function, Text)),
            (r'(?i)(Function|Fill|With|New|For|From|To|Of|End)', Keyword.Reserved),
            (r'(?i)(\+|\*|:=)', Name.Function),
            (r'(?i)(Matrix(?:es)?|Integers?)', Keyword.Type),
            (r'[0-9]+', Literal),
            (r'.', Text),
        ],
    }

