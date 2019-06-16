package cup.aug;
import java_cup.runtime.*;
import java.lang.*;
import java.io.InputStreamReader;

%%

%class Lexer
%implements sym
%unicode
%ignorecase
%cup

%{   
    String currentTagName = "";
%}

OpenTag = "<"
ClosingOpenTag = ">"
ClosingClosedTag = "/>"
OpeningClosingTag = "</"
StartLine = {OpenTag}"!doctype html"[^>]*{ClosingOpenTag}
WhiteSpace = \r|\n|\r\n | [ \t\f]
TagName = [a-zA-Z]+
Content = [^<(</)]*
Attributes = " "[^>(/>)]*

%state MAIN
%state STARTTAG
%state STARTCLOSINGTAG

%%

<YYINITIAL> {

	{StartLine}    	{ System.out.println(yytext() + " begin MAIN"); yybegin(MAIN); }
	{WhiteSpace}    { System.out.println("white"); }
	
}

<MAIN> {

	{WhiteSpace}    		{ System.out.println("white"); }
	{OpenTag}    			{ System.out.println(yytext() + " begin STARTTAG"); yybegin(STARTTAG); }
	{OpeningClosingTag}    	{ System.out.println(yytext() + " begin STARTCLOSINGTAG"); yybegin(STARTCLOSINGTAG); }
	{Content}    			{ System.out.println("content: " + yytext()); }
}

<STARTTAG> {

	{TagName}    			{ System.out.println(yytext()); currentTagName = yytext();}
	{Attributes}    		{ System.out.println(yytext());/* ignore */ }
	{ClosingOpenTag}    	{ System.out.println(yytext() + " begin MAIN"); yybegin(MAIN); return new Symbol(OPEN_TAG, currentTagName); }
	{ClosingClosedTag}    	{ System.out.println(yytext() + " begin MAIN"); yybegin(MAIN); return new Symbol(CLOSED_TAG, currentTagName); }
	{WhiteSpace}    		{ System.out.println("white"); }

}

<STARTCLOSINGTAG> {

	{TagName}    		{ System.out.println(yytext()); currentTagName = yytext();}
	{ClosingOpenTag}    { System.out.println(yytext() + " begin MAIN"); yybegin(MAIN); return new Symbol(CLOSING_TAG, currentTagName); }
	{WhiteSpace}    		{ System.out.println("white"); }
	
}

[^]     { throw new Error("Illegal character: "+yytext()); }