package cup.aug;
import java_cup.runtime.ComplexSymbolFactory;
import java_cup.runtime.ComplexSymbolFactory.Location;
import java_cup.runtime.Symbol;
import java.lang.*;
import java.io.InputStreamReader;

%%

%class Lexer
%implements sym
%unicode
%ignorecase
%line
%column
%char
%cup

%{  
     
    private ComplexSymbolFactory symbolFactory;
    private String currentTagName = "";
    
    public Lexer(ComplexSymbolFactory sf, java.io.InputStream is) {
		this(is);
        symbolFactory = sf;
    }
    
	public Lexer(ComplexSymbolFactory sf, java.io.Reader reader) {
		this(reader);
        symbolFactory = sf;
    }
    
    public Symbol symbol(String name, int code, String currentTagName){
		return symbolFactory.newSymbol(name, code, 
						new Location(yyline+1, yycolumn +1, yychar), 
						new Location(yyline+1,yycolumn+yylength(), yychar+yylength()), currentTagName);
    }

%}
/*komentarze jeszcze*/
StartLine = "<!doctype html"[^>]*">"
WhiteSpace = \r|\n|\r\n | [ \t\f]
TagName = [a-zA-Z0-9]+
Content = [^<(</)]*
Attributes = (" "[a-zA-Z]+(=("[^\"]*"|[a-zA-Z]*)))+

%eofval{
    return symbolFactory.newSymbol("EOF",sym.EOF);
%eofval}

%state MAIN
%state STARTTAG
%state STARTCLOSINGTAG

%%

<YYINITIAL> {

	{StartLine}    	{ System.out.println(yytext() + " begin MAIN"); yybegin(MAIN); }
	{WhiteSpace}    { /* ignore */ }
	
}

<MAIN> {

	{WhiteSpace}    		{ /* ignore */ }
	"<"    					{ System.out.println(yytext() + " begin STARTTAG"); yybegin(STARTTAG); }
	"</"    		{ System.out.println(yytext() + " begin STARTCLOSINGTAG"); yybegin(STARTCLOSINGTAG); }
	{Content}    			{ /* ignore */ }
}

<STARTTAG> {

	{TagName}    			{ System.out.println(yytext()); currentTagName = yytext();}
	{Attributes}    		{ /* ignore */ }
	"/>"    		{ System.out.println(" -> CLOSING_TAG  begin MAIN"); yybegin(MAIN); return symbolFactory.newSymbol("CLOSING_TAG", CLOSING_TAG, currentTagName); }
	">"		    			{ System.out.println(" -> OPEN_TAG begin MAIN " + currentTagName); yybegin(MAIN); return symbolFactory.newSymbol("OPEN_TAG", OPEN_TAG, currentTagName); }
	{WhiteSpace}    		{ /* ignore */ }

}

<STARTCLOSINGTAG> {

	{TagName}    		{ System.out.println(yytext()); currentTagName = yytext();}
	">"		    		{ System.out.println(" -> CLOSED_TAG  begin MAIN"); yybegin(MAIN); return symbolFactory.newSymbol("CLOSED_TAG", CLOSED_TAG, currentTagName); }
	{WhiteSpace}    	{ /* ignore */ }
	
}

[^]     { throw new Error("Illegal character: "+yytext()); }