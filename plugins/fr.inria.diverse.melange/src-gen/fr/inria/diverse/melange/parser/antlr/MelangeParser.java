/*
 * generated by Xtext
 */
package fr.inria.diverse.melange.parser.antlr;

import com.google.inject.Inject;

import org.eclipse.xtext.parser.antlr.XtextTokenStream;
import fr.inria.diverse.melange.services.MelangeGrammarAccess;

public class MelangeParser extends org.eclipse.xtext.parser.antlr.AbstractAntlrParser {
	
	@Inject
	private MelangeGrammarAccess grammarAccess;
	
	@Override
	protected void setInitialHiddenTokens(XtextTokenStream tokenStream) {
		tokenStream.setInitialHiddenTokens("RULE_WS", "RULE_ML_COMMENT", "RULE_SL_COMMENT");
	}
	
	@Override
	protected fr.inria.diverse.melange.parser.antlr.internal.InternalMelangeParser createParser(XtextTokenStream stream) {
		return new fr.inria.diverse.melange.parser.antlr.internal.InternalMelangeParser(stream, getGrammarAccess());
	}
	
	@Override 
	protected String getDefaultRuleName() {
		return "ModelTypingSpace";
	}
	
	public MelangeGrammarAccess getGrammarAccess() {
		return this.grammarAccess;
	}
	
	public void setGrammarAccess(MelangeGrammarAccess grammarAccess) {
		this.grammarAccess = grammarAccess;
	}
	
}
