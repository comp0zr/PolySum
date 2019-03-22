from pygments.lexer import RegexLexer, bygroups
from pygments.token import *

class AlgLexer(RegexLexer):
    tokens = {
        'root': [
            (r'(?i)([\w\-]+)(\()', bygroups(Name.Function, Name)),
            (r'(?i)(Função|Preencha|com|Nov[oa]|Para|De|Até|Fim)', Keyword.Reserved),
            (r'(?i)(\+|\*|-|:=)', Operator),
            (r'(?i)(Matriz(?:es)?|Inteiros?)', Keyword.Type),
            (r'[0-9]+', Literal),
            (r'.', Name),
        ],
    }

