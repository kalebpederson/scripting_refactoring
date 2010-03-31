grammar ScriptableRefactorings;

/* make it runnable */

@header {
import org.antlr.runtime.*;
}


@members {
    public static void main(String[] args) throws Exception {
        ANTLRInputStream input =
			new ANTLRInputStream(System.in);
        ScriptableRefactoringsLexer lexer =
			new ScriptableRefactoringsLexer (input);
        CommonTokenStream tokens =
			new CommonTokenStream(lexer);
        ScriptableRefactoringsParser parser =
        	new ScriptableRefactoringsParser(tokens);
        parser.script();
    }

} // end @members


/*** PARSER RULES ***/

script	:	
	opts? refactoring+ EOF;

// opts is a section that allows options specific to the command
// line to be specified within the refactoring script file rather
// than on the command line.
opts	:	'@options' '{' ~('}')+ '}';

refactoring:
	ID block ';'?; 

block:
	'{' parameterSequence (';' parameterSequence)* ';' '}';

parameterSequence:
	parameter (',' parameter)*;

parameter
	:	simpleParameter
	|	namedParameter;

simpleParameter:
	dataType;

namedParameter
	:	parameterName '=' dataType;
	
parameterName
	:	ID;

elementRegExp:
	'/' ~'/'* '/';

dataType	:
	basicType
	| positionMarker
	| elementReference
	| elementReferenceArray;

elementReference
	:	nonArrayElementComponent
			(SCOPE_OPERATOR elementComponent)*
	|	SCOPE_OPERATOR elementComponent;

elementComponent
	:	elementId typeRestriction? indexRestriction?
	|	elementIdArray typeRestriction? indexRestriction?
	|	typeRestriction indexRestriction?;

nonArrayElementComponent
	:	elementId typeRestriction? indexRestriction?
	|	typeRestriction indexRestriction?;
	
// this restriction could be relaxed to support lists of valid
// elements, inverted sets, etc.
indexRestriction
	:	'[' INTEGER ']';

elementReferenceArray
	:	'[' elementReference (',' elementReference)* ']';

elementId
	:	ID
	|	elementRegExp;

elementIdArray
	:	'[' (ID | elementRegExp)
			(',' (ID | elementRegExp))* ']';
	
positionMarker
	:	'@' '(' positionMarkerAtom
			(('+'|'-') positionMarkerAtom)* ')';

positionMarkerAtom
	:	LINE_COLUMN_REFERENCE
	|	INTEGER
	|	elementReference
		;

// I need to change this to a full blown expression grammar with &&,
// ||, !, and parenthesis.
typeRestriction
	:	'{' idExpr '}';

idExpr	:	idAtom (('||' | '&&') idAtom)*;

idAtom	:	ID
	|	'!' ID
	|	'(' idExpr ')';

idWithBackReferences
	:	( 'a'..'z' | 'A'..'Z' | '_' | BACKREFERENCE)
		( 'a'..'z' | 'A'..'Z' | '_' | DIGITS | BACKREFERENCE)*;

basicType
	:	STRING
	|	INTEGER
	|	LONG
	|	DOUBLE
	|	BOOLEAN
	|	LINE_COLUMN_REFERENCE;

	

/*** LEXER RULES ***/

WHITESPACE : ( '\t' | ' ' | '\r' | '\n'| '\u000C' )+
				{ $channel = HIDDEN; } ;


SINGLE_COMMENT
	:	'//' ~('\r' | '\n')* NEWLINE { skip(); };

MULTI_COMMENT
 	:	'/*' (.*)'*/' NEWLINE? { skip(); };

ID	:	( 'a'..'z' | 'A'..'Z' | '_' | BACKREFERENCE)
		(  'a'..'z' | 'A'..'Z' | '_' | DIGITS | BACKREFERENCE )*;

STRING
	:	'"' ~'"'* '"';

SCOPE_OPERATOR
	:	'::';

INTEGER
	:	'1'..'9' DIGITS*;

LONG	:	INTEGER 'L';

BOOLEAN
	:	'true' | 'false';

DOUBLE
	:	('1'..'9' DIGITS*)? '.' DIGITS+;
	
LINE_COLUMN_REFERENCE
	:	INTEGER ':' INTEGER;

fragment ID_NO_BACKREFERENCES
	:	( 'a'..'z' | 'A'..'Z' | '_'  )
		( 'a'..'z' | 'A'..'Z' | '_' | DIGITS)*;
	
fragment DIGITS
	:	'0'..'9';

fragment BACKREFERENCE
	:	'\\' INTEGER 
	|	'(?P=' ID_NO_BACKREFERENCES ')';

fragment NEWLINE	
	: 	('\r'? '\n')+;

