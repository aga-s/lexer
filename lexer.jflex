package cup.aug;
import java_cup.runtime.ComplexSymbolFactory;
import java_cup.runtime.ComplexSymbolFactory.Location;
import java_cup.runtime.Symbol;
import java.lang.*;
import java.util.Map;
import java.util.HashMap;
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
    private Map<String, Integer> startTagsMap = new HashMap<>();
    private Map<String, Integer> endTagsMap = new HashMap<>();
    
    public Lexer(ComplexSymbolFactory sf, java.io.InputStream is) {
		this(is);
        symbolFactory = sf;
        putStartTags();
        putEndTags();
    }
    
	public Lexer(ComplexSymbolFactory sf, java.io.Reader reader) {
		this(reader);
        symbolFactory = sf;
        putStartTags();
        putEndTags();
    }
    
    private void putStartTags() {
    	//main elements:
    	startTagsMap.put("html", HTML_OPEN);
    	startTagsMap.put("head", HEAD_OPEN);
    	startTagsMap.put("body", BODY_OPEN);
    	//void elements:
    	startTagsMap.put("area", SINGLE_TAG);
    	startTagsMap.put("col", SINGLE_TAG);
    	startTagsMap.put("embed", SINGLE_TAG);
    	startTagsMap.put("hr", SINGLE_TAG);
    	startTagsMap.put("input", SINGLE_TAG);
    	startTagsMap.put("param", SINGLE_TAG);
    	startTagsMap.put("source", SINGLE_TAG);
    	startTagsMap.put("track", SINGLE_TAG);
    	startTagsMap.put("wbr", SINGLE_TAG);
    	//void elements in head:
    	startTagsMap.put("base", IN_HEAD_TAG);
    	startTagsMap.put("link", IN_HEAD_TAG);
    	startTagsMap.put("meta", IN_HEAD_TAG);
    	//normal elements in head:
    	startTagsMap.put("title", TITLE_TAG_OPEN); //only once
    	startTagsMap.put("style", IN_HEAD_TAG_OPEN);
    	startTagsMap.put("script", IN_HEAD_TAG_OPEN);
    	startTagsMap.put("noscript", IN_HEAD_TAG_OPEN);
    	//a,p,h:
    	startTagsMap.put("a", A_TAG_OPEN); //a can be nested also in a,p,h
    	startTagsMap.put("p", A_P_H_TAG_OPEN);
    	startTagsMap.put("h1", A_P_H_TAG_OPEN);
    	startTagsMap.put("h2", A_P_H_TAG_OPEN);
    	startTagsMap.put("h3", A_P_H_TAG_OPEN);
    	startTagsMap.put("h4", A_P_H_TAG_OPEN);
    	startTagsMap.put("h5", A_P_H_TAG_OPEN);
    	startTagsMap.put("h6", A_P_H_TAG_OPEN);
    	//void elements in a,p,h
    	startTagsMap.put("br", IN_TEXT_TAG);
    	startTagsMap.put("img", IN_TEXT_TAG);
    	//normal elements in a,p,h
    	startTagsMap.put("b", IN_TEXT_TAG_OPEN);
    	startTagsMap.put("em", IN_TEXT_TAG_OPEN);
    	startTagsMap.put("strong", IN_TEXT_TAG_OPEN);
    	startTagsMap.put("pre", IN_TEXT_TAG_OPEN);
    	startTagsMap.put("span", IN_TEXT_TAG_OPEN);
    	startTagsMap.put("label", IN_TEXT_TAG_OPEN);
    	//table:
    	startTagsMap.put("table", TABLE_TAG_OPEN);
    	startTagsMap.put("tr", ROW_TAG_OPEN);
    	startTagsMap.put("th", HEADER_TAG_OPEN);
    	startTagsMap.put("td", CELL_TAG_OPEN);
    	//ol, ul, li
    	startTagsMap.put("ol", LIST_TAG_OPEN);
    	startTagsMap.put("ul", LIST_TAG_OPEN);
    	startTagsMap.put("li", ITEM_TAG_OPEN);
    	//div
    	startTagsMap.put("div", DIV_TAG_OPEN);
    	
    }
    
    private void putEndTags() {
    	//main elements:
    	endTagsMap.put("html", HTML_CLOSE);
    	endTagsMap.put("head", HEAD_CLOSE);
    	endTagsMap.put("body", BODY_CLOSE);
    	//normal elements in head:
    	endTagsMap.put("title", TITLE_TAG_CLOSE); //only once
    	endTagsMap.put("style", IN_HEAD_TAG_CLOSE);
    	endTagsMap.put("script", IN_HEAD_TAG_CLOSE);
    	endTagsMap.put("noscript", IN_HEAD_TAG_CLOSE);
    	//a,p,h:
    	endTagsMap.put("a", A_TAG_CLOSE);
    	endTagsMap.put("p", A_P_H_TAG_CLOSE);
    	endTagsMap.put("h1", A_P_H_TAG_CLOSE);
    	endTagsMap.put("h2", A_P_H_TAG_CLOSE);
    	endTagsMap.put("h3", A_P_H_TAG_CLOSE);
    	endTagsMap.put("h4", A_P_H_TAG_CLOSE);
    	endTagsMap.put("h5", A_P_H_TAG_CLOSE);
    	endTagsMap.put("h6", A_P_H_TAG_CLOSE);
    	//normal elements in a,p,h:
    	endTagsMap.put("b", IN_TEXT_TAG_CLOSE);
    	endTagsMap.put("em", IN_TEXT_TAG_CLOSE);
    	endTagsMap.put("strong", IN_TEXT_TAG_CLOSE);
    	endTagsMap.put("pre", IN_TEXT_TAG_CLOSE);
    	endTagsMap.put("span", IN_TEXT_TAG_CLOSE);
    	endTagsMap.put("label", IN_TEXT_TAG_CLOSE);
    	//table:
    	endTagsMap.put("table", TABLE_TAG_CLOSE);
    	endTagsMap.put("tr", ROW_TAG_CLOSE);
    	endTagsMap.put("th", HEADER_TAG_CLOSE);
    	endTagsMap.put("td", CELL_TAG_CLOSE);
    	//ol, ul, li
    	endTagsMap.put("ol", LIST_TAG_CLOSE);
    	endTagsMap.put("ul", LIST_TAG_CLOSE);
    	endTagsMap.put("li", ITEM_TAG_CLOSE);
    	//div
    	endTagsMap.put("div", DIV_TAG_CLOSE);    
    }
    
    private Symbol getSymbol(int code, String value) {
    	return symbolFactory.newSymbol(terminalNames[code], code, value);
    }

%}

StartLine = "<!doctype html"[^>]*">"
WhiteSpace = \r|\n|\r\n | [ \t\f]
Attributes = {WhiteSpace}*[a-zA-Z]+(=(\"[^\"]*\"|[a-zA-Z]*))
TagName = [a-zA-Z0-9]+
Content = [^<]*
InsideComment = .*?
Comment = "<!--"{InsideComment}"-->"

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
	{Comment}		{ /* ignore */ }
	
}

<MAIN> {

	"<"    					{ System.out.println("begin STARTTAG"); yybegin(STARTTAG); }
	"</"    				{ System.out.println("begin STARTCLOSINGTAG"); yybegin(STARTCLOSINGTAG); }
	{WhiteSpace}    		{ /* ignore */ }
	{Comment}				{ /* ignore */ }
	{Content}    			{ /* ignore */ }
}

<STARTTAG> {

	"/>"    				{ 	yybegin(MAIN);
								if (startTagsMap.containsKey(currentTagName)) {
									System.out.println("return start element from map, begin MAIN ");
									return getSymbol(startTagsMap.get(currentTagName), currentTagName);
								} else {
									System.out.println("return SINGLE_TAG, begin MAIN ");
									return symbolFactory.newSymbol("SINGLE_TAG", SINGLE_TAG, currentTagName); 
								}
							}
	">"		    			{ 	yybegin(MAIN);
								if (startTagsMap.containsKey(currentTagName)) {
									System.out.println("return start element from map, begin MAIN ");
									return getSymbol(startTagsMap.get(currentTagName), currentTagName);
								} else {
									System.out.println("return OPEN_TAG, begin MAIN ");
									return symbolFactory.newSymbol("OPEN_TAG", OPEN_TAG, currentTagName);
								}
							}
	{TagName}    			{ System.out.println(yytext()); currentTagName = yytext().toLowerCase();}
	{Attributes}    		{ /* ignore */ }
	{WhiteSpace}    		{ /* ignore */ }

}

<STARTCLOSINGTAG> {

	">"		    		{ 	yybegin(MAIN); 
							if (endTagsMap.containsKey(currentTagName)) {
								System.out.println("return end tag from map, begin MAIN ");
								return getSymbol(endTagsMap.get(currentTagName), currentTagName);
							} else {
								System.out.println("return CLOSE_TAG, begin MAIN ");
								return symbolFactory.newSymbol("CLOSE_TAG", CLOSE_TAG, currentTagName);
							}
						}
	{TagName}    		{ System.out.println(yytext()); currentTagName = yytext().toLowerCase();}
	{WhiteSpace}    	{ /* ignore */ }
	
}

[^]     { throw new Error("Illegal character: " + yytext()); }