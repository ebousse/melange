/*
 * generated by Xtext
 */
package fr.inria.diverse.iot2.serializer;

import com.google.inject.Inject;
import fr.inria.diverse.iot2.services.IoT2GrammarAccess;
import java.util.List;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.IGrammarAccess;
import org.eclipse.xtext.RuleCall;
import org.eclipse.xtext.nodemodel.INode;
import org.eclipse.xtext.serializer.analysis.GrammarAlias.AbstractElementAlias;
import org.eclipse.xtext.serializer.analysis.GrammarAlias.AlternativeAlias;
import org.eclipse.xtext.serializer.analysis.GrammarAlias.GroupAlias;
import org.eclipse.xtext.serializer.analysis.GrammarAlias.TokenAlias;
import org.eclipse.xtext.serializer.analysis.ISyntacticSequencerPDAProvider.ISynNavigable;
import org.eclipse.xtext.serializer.analysis.ISyntacticSequencerPDAProvider.ISynTransition;
import org.eclipse.xtext.serializer.sequencer.AbstractSyntacticSequencer;

@SuppressWarnings("all")
public abstract class AbstractIoT2SyntacticSequencer extends AbstractSyntacticSequencer {

	protected IoT2GrammarAccess grammarAccess;
	protected AbstractElementAlias match_Actuator___LeftCurlyBracketKeyword_2_0_RightCurlyBracketKeyword_2_2__q;
	protected AbstractElementAlias match_Block_SemicolonKeyword_1_1_q;
	protected AbstractElementAlias match_Block_SemicolonKeyword_2_1_q;
	protected AbstractElementAlias match_Board___LeftCurlyBracketKeyword_6_0_RightCurlyBracketKeyword_6_2__q;
	protected AbstractElementAlias match_Expression_TableConstructor_CommaKeyword_2_1_0_0_or_SemicolonKeyword_2_1_0_1;
	protected AbstractElementAlias match_Expression_TableConstructor___CommaKeyword_2_2_0_or_SemicolonKeyword_2_2_1__q;
	protected AbstractElementAlias match_Expression_VariableName_LeftParenthesisKeyword_0_0_a;
	protected AbstractElementAlias match_Expression_VariableName_LeftParenthesisKeyword_0_0_p;
	protected AbstractElementAlias match_Function_CommaKeyword_1_2_q;
	protected AbstractElementAlias match_Sensor___LeftCurlyBracketKeyword_2_0_RightCurlyBracketKeyword_2_2__q;
	
	@Inject
	protected void init(IGrammarAccess access) {
		grammarAccess = (IoT2GrammarAccess) access;
		match_Actuator___LeftCurlyBracketKeyword_2_0_RightCurlyBracketKeyword_2_2__q = new GroupAlias(false, true, new TokenAlias(false, false, grammarAccess.getActuatorAccess().getLeftCurlyBracketKeyword_2_0()), new TokenAlias(false, false, grammarAccess.getActuatorAccess().getRightCurlyBracketKeyword_2_2()));
		match_Block_SemicolonKeyword_1_1_q = new TokenAlias(false, true, grammarAccess.getBlockAccess().getSemicolonKeyword_1_1());
		match_Block_SemicolonKeyword_2_1_q = new TokenAlias(false, true, grammarAccess.getBlockAccess().getSemicolonKeyword_2_1());
		match_Board___LeftCurlyBracketKeyword_6_0_RightCurlyBracketKeyword_6_2__q = new GroupAlias(false, true, new TokenAlias(false, false, grammarAccess.getBoardAccess().getLeftCurlyBracketKeyword_6_0()), new TokenAlias(false, false, grammarAccess.getBoardAccess().getRightCurlyBracketKeyword_6_2()));
		match_Expression_TableConstructor_CommaKeyword_2_1_0_0_or_SemicolonKeyword_2_1_0_1 = new AlternativeAlias(false, false, new TokenAlias(false, false, grammarAccess.getExpression_TableConstructorAccess().getCommaKeyword_2_1_0_0()), new TokenAlias(false, false, grammarAccess.getExpression_TableConstructorAccess().getSemicolonKeyword_2_1_0_1()));
		match_Expression_TableConstructor___CommaKeyword_2_2_0_or_SemicolonKeyword_2_2_1__q = new AlternativeAlias(false, true, new TokenAlias(false, false, grammarAccess.getExpression_TableConstructorAccess().getCommaKeyword_2_2_0()), new TokenAlias(false, false, grammarAccess.getExpression_TableConstructorAccess().getSemicolonKeyword_2_2_1()));
		match_Expression_VariableName_LeftParenthesisKeyword_0_0_a = new TokenAlias(true, true, grammarAccess.getExpression_VariableNameAccess().getLeftParenthesisKeyword_0_0());
		match_Expression_VariableName_LeftParenthesisKeyword_0_0_p = new TokenAlias(true, false, grammarAccess.getExpression_VariableNameAccess().getLeftParenthesisKeyword_0_0());
		match_Function_CommaKeyword_1_2_q = new TokenAlias(false, true, grammarAccess.getFunctionAccess().getCommaKeyword_1_2());
		match_Sensor___LeftCurlyBracketKeyword_2_0_RightCurlyBracketKeyword_2_2__q = new GroupAlias(false, true, new TokenAlias(false, false, grammarAccess.getSensorAccess().getLeftCurlyBracketKeyword_2_0()), new TokenAlias(false, false, grammarAccess.getSensorAccess().getRightCurlyBracketKeyword_2_2()));
	}
	
	@Override
	protected String getUnassignedRuleCallToken(EObject semanticObject, RuleCall ruleCall, INode node) {
		return "";
	}
	
	
	@Override
	protected void emitUnassignedTokens(EObject semanticObject, ISynTransition transition, INode fromNode, INode toNode) {
		if (transition.getAmbiguousSyntaxes().isEmpty()) return;
		List<INode> transitionNodes = collectNodes(fromNode, toNode);
		for (AbstractElementAlias syntax : transition.getAmbiguousSyntaxes()) {
			List<INode> syntaxNodes = getNodesFor(transitionNodes, syntax);
			if(match_Actuator___LeftCurlyBracketKeyword_2_0_RightCurlyBracketKeyword_2_2__q.equals(syntax))
				emit_Actuator___LeftCurlyBracketKeyword_2_0_RightCurlyBracketKeyword_2_2__q(semanticObject, getLastNavigableState(), syntaxNodes);
			else if(match_Block_SemicolonKeyword_1_1_q.equals(syntax))
				emit_Block_SemicolonKeyword_1_1_q(semanticObject, getLastNavigableState(), syntaxNodes);
			else if(match_Block_SemicolonKeyword_2_1_q.equals(syntax))
				emit_Block_SemicolonKeyword_2_1_q(semanticObject, getLastNavigableState(), syntaxNodes);
			else if(match_Board___LeftCurlyBracketKeyword_6_0_RightCurlyBracketKeyword_6_2__q.equals(syntax))
				emit_Board___LeftCurlyBracketKeyword_6_0_RightCurlyBracketKeyword_6_2__q(semanticObject, getLastNavigableState(), syntaxNodes);
			else if(match_Expression_TableConstructor_CommaKeyword_2_1_0_0_or_SemicolonKeyword_2_1_0_1.equals(syntax))
				emit_Expression_TableConstructor_CommaKeyword_2_1_0_0_or_SemicolonKeyword_2_1_0_1(semanticObject, getLastNavigableState(), syntaxNodes);
			else if(match_Expression_TableConstructor___CommaKeyword_2_2_0_or_SemicolonKeyword_2_2_1__q.equals(syntax))
				emit_Expression_TableConstructor___CommaKeyword_2_2_0_or_SemicolonKeyword_2_2_1__q(semanticObject, getLastNavigableState(), syntaxNodes);
			else if(match_Expression_VariableName_LeftParenthesisKeyword_0_0_a.equals(syntax))
				emit_Expression_VariableName_LeftParenthesisKeyword_0_0_a(semanticObject, getLastNavigableState(), syntaxNodes);
			else if(match_Expression_VariableName_LeftParenthesisKeyword_0_0_p.equals(syntax))
				emit_Expression_VariableName_LeftParenthesisKeyword_0_0_p(semanticObject, getLastNavigableState(), syntaxNodes);
			else if(match_Function_CommaKeyword_1_2_q.equals(syntax))
				emit_Function_CommaKeyword_1_2_q(semanticObject, getLastNavigableState(), syntaxNodes);
			else if(match_Sensor___LeftCurlyBracketKeyword_2_0_RightCurlyBracketKeyword_2_2__q.equals(syntax))
				emit_Sensor___LeftCurlyBracketKeyword_2_0_RightCurlyBracketKeyword_2_2__q(semanticObject, getLastNavigableState(), syntaxNodes);
			else acceptNodes(getLastNavigableState(), syntaxNodes);
		}
	}

	/**
	 * Ambiguous syntax:
	 *     ('{' '}')?
	 *
	 * This ambiguous syntax occurs at:
	 *     name=ID (ambiguity) (rule end)
	 */
	protected void emit_Actuator___LeftCurlyBracketKeyword_2_0_RightCurlyBracketKeyword_2_2__q(EObject semanticObject, ISynNavigable transition, List<INode> nodes) {
		acceptNodes(transition, nodes);
	}
	
	/**
	 * Ambiguous syntax:
	 *     ';'?
	 *
	 * This ambiguous syntax occurs at:
	 *     statements+=Statement (ambiguity) (rule end)
	 *     statements+=Statement (ambiguity) returnValue=LastStatement
	 *     statements+=Statement (ambiguity) statements+=Statement
	 */
	protected void emit_Block_SemicolonKeyword_1_1_q(EObject semanticObject, ISynNavigable transition, List<INode> nodes) {
		acceptNodes(transition, nodes);
	}
	
	/**
	 * Ambiguous syntax:
	 *     ';'?
	 *
	 * This ambiguous syntax occurs at:
	 *     returnValue=LastStatement (ambiguity) (rule end)
	 */
	protected void emit_Block_SemicolonKeyword_2_1_q(EObject semanticObject, ISynNavigable transition, List<INode> nodes) {
		acceptNodes(transition, nodes);
	}
	
	/**
	 * Ambiguous syntax:
	 *     ('{' '}')?
	 *
	 * This ambiguous syntax occurs at:
	 *     type=BoardType ']' (ambiguity) (rule end)
	 */
	protected void emit_Board___LeftCurlyBracketKeyword_6_0_RightCurlyBracketKeyword_6_2__q(EObject semanticObject, ISynNavigable transition, List<INode> nodes) {
		acceptNodes(transition, nodes);
	}
	
	/**
	 * Ambiguous syntax:
	 *     ',' | ';'
	 *
	 * This ambiguous syntax occurs at:
	 *     fields+=Field (ambiguity) fields+=Field
	 */
	protected void emit_Expression_TableConstructor_CommaKeyword_2_1_0_0_or_SemicolonKeyword_2_1_0_1(EObject semanticObject, ISynNavigable transition, List<INode> nodes) {
		acceptNodes(transition, nodes);
	}
	
	/**
	 * Ambiguous syntax:
	 *     (',' | ';')?
	 *
	 * This ambiguous syntax occurs at:
	 *     fields+=Field (ambiguity) '}' '%' (rule end)
	 *     fields+=Field (ambiguity) '}' ')' '.' (rule end)
	 *     fields+=Field (ambiguity) '}' ')' ':' (rule end)
	 *     fields+=Field (ambiguity) '}' ')' '[' (rule end)
	 *     fields+=Field (ambiguity) '}' ')' (rule end)
	 *     fields+=Field (ambiguity) '}' '*' (rule end)
	 *     fields+=Field (ambiguity) '}' '+' (rule end)
	 *     fields+=Field (ambiguity) '}' '-' (rule end)
	 *     fields+=Field (ambiguity) '}' '..' (rule end)
	 *     fields+=Field (ambiguity) '}' '/' (rule end)
	 *     fields+=Field (ambiguity) '}' '<' (rule end)
	 *     fields+=Field (ambiguity) '}' '<=' (rule end)
	 *     fields+=Field (ambiguity) '}' '==' (rule end)
	 *     fields+=Field (ambiguity) '}' '>' (rule end)
	 *     fields+=Field (ambiguity) '}' '>=' (rule end)
	 *     fields+=Field (ambiguity) '}' '^' (rule end)
	 *     fields+=Field (ambiguity) '}' 'and' (rule end)
	 *     fields+=Field (ambiguity) '}' 'or' (rule end)
	 *     fields+=Field (ambiguity) '}' '~=' (rule end)
	 *     fields+=Field (ambiguity) '}' (rule end)
	 */
	protected void emit_Expression_TableConstructor___CommaKeyword_2_2_0_or_SemicolonKeyword_2_2_1__q(EObject semanticObject, ISynNavigable transition, List<INode> nodes) {
		acceptNodes(transition, nodes);
	}
	
	/**
	 * Ambiguous syntax:
	 *     '('*
	 *
	 * This ambiguous syntax occurs at:
	 *     (rule start) (ambiguity) '#' exp=Expression_Unary
	 *     (rule start) (ambiguity) '-' exp=Expression_Unary
	 *     (rule start) (ambiguity) '...' '%' (rule start)
	 *     (rule start) (ambiguity) '...' '*' (rule start)
	 *     (rule start) (ambiguity) '...' '+' (rule start)
	 *     (rule start) (ambiguity) '...' '-' (rule start)
	 *     (rule start) (ambiguity) '...' '..' (rule start)
	 *     (rule start) (ambiguity) '...' '/' (rule start)
	 *     (rule start) (ambiguity) '...' '<' (rule start)
	 *     (rule start) (ambiguity) '...' '<=' (rule start)
	 *     (rule start) (ambiguity) '...' '==' (rule start)
	 *     (rule start) (ambiguity) '...' '>' (rule start)
	 *     (rule start) (ambiguity) '...' '>=' (rule start)
	 *     (rule start) (ambiguity) '...' '^' (rule start)
	 *     (rule start) (ambiguity) '...' 'and' (rule start)
	 *     (rule start) (ambiguity) '...' 'or' (rule start)
	 *     (rule start) (ambiguity) '...' '~=' (rule start)
	 *     (rule start) (ambiguity) '...' (rule start)
	 *     (rule start) (ambiguity) 'false' '%' (rule start)
	 *     (rule start) (ambiguity) 'false' '*' (rule start)
	 *     (rule start) (ambiguity) 'false' '+' (rule start)
	 *     (rule start) (ambiguity) 'false' '-' (rule start)
	 *     (rule start) (ambiguity) 'false' '..' (rule start)
	 *     (rule start) (ambiguity) 'false' '/' (rule start)
	 *     (rule start) (ambiguity) 'false' '<' (rule start)
	 *     (rule start) (ambiguity) 'false' '<=' (rule start)
	 *     (rule start) (ambiguity) 'false' '==' (rule start)
	 *     (rule start) (ambiguity) 'false' '>' (rule start)
	 *     (rule start) (ambiguity) 'false' '>=' (rule start)
	 *     (rule start) (ambiguity) 'false' '^' (rule start)
	 *     (rule start) (ambiguity) 'false' 'and' (rule start)
	 *     (rule start) (ambiguity) 'false' 'or' (rule start)
	 *     (rule start) (ambiguity) 'false' '~=' (rule start)
	 *     (rule start) (ambiguity) 'false' (rule start)
	 *     (rule start) (ambiguity) 'function' function=Function
	 *     (rule start) (ambiguity) 'nil' '%' (rule start)
	 *     (rule start) (ambiguity) 'nil' '*' (rule start)
	 *     (rule start) (ambiguity) 'nil' '+' (rule start)
	 *     (rule start) (ambiguity) 'nil' '-' (rule start)
	 *     (rule start) (ambiguity) 'nil' '..' (rule start)
	 *     (rule start) (ambiguity) 'nil' '/' (rule start)
	 *     (rule start) (ambiguity) 'nil' '<' (rule start)
	 *     (rule start) (ambiguity) 'nil' '<=' (rule start)
	 *     (rule start) (ambiguity) 'nil' '==' (rule start)
	 *     (rule start) (ambiguity) 'nil' '>' (rule start)
	 *     (rule start) (ambiguity) 'nil' '>=' (rule start)
	 *     (rule start) (ambiguity) 'nil' '^' (rule start)
	 *     (rule start) (ambiguity) 'nil' 'and' (rule start)
	 *     (rule start) (ambiguity) 'nil' 'or' (rule start)
	 *     (rule start) (ambiguity) 'nil' '~=' (rule start)
	 *     (rule start) (ambiguity) 'nil' (rule start)
	 *     (rule start) (ambiguity) 'not' exp=Expression_Unary
	 *     (rule start) (ambiguity) 'true' '%' (rule start)
	 *     (rule start) (ambiguity) 'true' '*' (rule start)
	 *     (rule start) (ambiguity) 'true' '+' (rule start)
	 *     (rule start) (ambiguity) 'true' '-' (rule start)
	 *     (rule start) (ambiguity) 'true' '..' (rule start)
	 *     (rule start) (ambiguity) 'true' '/' (rule start)
	 *     (rule start) (ambiguity) 'true' '<' (rule start)
	 *     (rule start) (ambiguity) 'true' '<=' (rule start)
	 *     (rule start) (ambiguity) 'true' '==' (rule start)
	 *     (rule start) (ambiguity) 'true' '>' (rule start)
	 *     (rule start) (ambiguity) 'true' '>=' (rule start)
	 *     (rule start) (ambiguity) 'true' '^' (rule start)
	 *     (rule start) (ambiguity) 'true' 'and' (rule start)
	 *     (rule start) (ambiguity) 'true' 'or' (rule start)
	 *     (rule start) (ambiguity) 'true' '~=' (rule start)
	 *     (rule start) (ambiguity) 'true' (rule start)
	 *     (rule start) (ambiguity) '{' '}' '%' (rule start)
	 *     (rule start) (ambiguity) '{' '}' '*' (rule start)
	 *     (rule start) (ambiguity) '{' '}' '+' (rule start)
	 *     (rule start) (ambiguity) '{' '}' '-' (rule start)
	 *     (rule start) (ambiguity) '{' '}' '..' (rule start)
	 *     (rule start) (ambiguity) '{' '}' '/' (rule start)
	 *     (rule start) (ambiguity) '{' '}' '<' (rule start)
	 *     (rule start) (ambiguity) '{' '}' '<=' (rule start)
	 *     (rule start) (ambiguity) '{' '}' '==' (rule start)
	 *     (rule start) (ambiguity) '{' '}' '>' (rule start)
	 *     (rule start) (ambiguity) '{' '}' '>=' (rule start)
	 *     (rule start) (ambiguity) '{' '}' '^' (rule start)
	 *     (rule start) (ambiguity) '{' '}' 'and' (rule start)
	 *     (rule start) (ambiguity) '{' '}' 'or' (rule start)
	 *     (rule start) (ambiguity) '{' '}' '~=' (rule start)
	 *     (rule start) (ambiguity) '{' '}' (rule start)
	 *     (rule start) (ambiguity) '{' fields+=Field
	 *     (rule start) (ambiguity) value=LUA_NUMBER
	 *     (rule start) (ambiguity) value=STRING
	 *     (rule start) (ambiguity) variable=ID
	 *     (rule start) (ambiguity) {Expression_AccessArray.array=}
	 *     (rule start) (ambiguity) {Expression_AccessMember.object=}
	 *     (rule start) (ambiguity) {Expression_And.left=}
	 *     (rule start) (ambiguity) {Expression_CallFunction.object=}
	 *     (rule start) (ambiguity) {Expression_CallMemberFunction.object=}
	 *     (rule start) (ambiguity) {Expression_Concatenation.left=}
	 *     (rule start) (ambiguity) {Expression_Division.left=}
	 *     (rule start) (ambiguity) {Expression_Equal.left=}
	 *     (rule start) (ambiguity) {Expression_Exponentiation.left=}
	 *     (rule start) (ambiguity) {Expression_Larger.left=}
	 *     (rule start) (ambiguity) {Expression_Larger_Equal.left=}
	 *     (rule start) (ambiguity) {Expression_Minus.left=}
	 *     (rule start) (ambiguity) {Expression_Modulo.left=}
	 *     (rule start) (ambiguity) {Expression_Multiplication.left=}
	 *     (rule start) (ambiguity) {Expression_Not_Equal.left=}
	 *     (rule start) (ambiguity) {Expression_Or.left=}
	 *     (rule start) (ambiguity) {Expression_Plus.left=}
	 *     (rule start) (ambiguity) {Expression_Smaller.left=}
	 *     (rule start) (ambiguity) {Expression_Smaller_Equal.left=}
	 */
	protected void emit_Expression_VariableName_LeftParenthesisKeyword_0_0_a(EObject semanticObject, ISynNavigable transition, List<INode> nodes) {
		acceptNodes(transition, nodes);
	}
	
	/**
	 * Ambiguous syntax:
	 *     '('+
	 *
	 * This ambiguous syntax occurs at:
	 *     (rule start) (ambiguity) '#' exp=Expression_Unary
	 *     (rule start) (ambiguity) '-' exp=Expression_Unary
	 *     (rule start) (ambiguity) '...' ')' '.' (rule start)
	 *     (rule start) (ambiguity) '...' ')' ':' (rule start)
	 *     (rule start) (ambiguity) '...' ')' '[' (rule start)
	 *     (rule start) (ambiguity) '...' ')' (rule start)
	 *     (rule start) (ambiguity) 'false' ')' '.' (rule start)
	 *     (rule start) (ambiguity) 'false' ')' ':' (rule start)
	 *     (rule start) (ambiguity) 'false' ')' '[' (rule start)
	 *     (rule start) (ambiguity) 'false' ')' (rule start)
	 *     (rule start) (ambiguity) 'function' function=Function
	 *     (rule start) (ambiguity) 'nil' ')' '.' (rule start)
	 *     (rule start) (ambiguity) 'nil' ')' ':' (rule start)
	 *     (rule start) (ambiguity) 'nil' ')' '[' (rule start)
	 *     (rule start) (ambiguity) 'nil' ')' (rule start)
	 *     (rule start) (ambiguity) 'not' exp=Expression_Unary
	 *     (rule start) (ambiguity) 'true' ')' '.' (rule start)
	 *     (rule start) (ambiguity) 'true' ')' ':' (rule start)
	 *     (rule start) (ambiguity) 'true' ')' '[' (rule start)
	 *     (rule start) (ambiguity) 'true' ')' (rule start)
	 *     (rule start) (ambiguity) '{' '}' ')' '.' (rule start)
	 *     (rule start) (ambiguity) '{' '}' ')' ':' (rule start)
	 *     (rule start) (ambiguity) '{' '}' ')' '[' (rule start)
	 *     (rule start) (ambiguity) '{' '}' ')' (rule start)
	 *     (rule start) (ambiguity) '{' fields+=Field
	 *     (rule start) (ambiguity) value=LUA_NUMBER
	 *     (rule start) (ambiguity) value=STRING
	 *     (rule start) (ambiguity) {Expression_AccessArray.array=}
	 *     (rule start) (ambiguity) {Expression_AccessMember.object=}
	 *     (rule start) (ambiguity) {Expression_And.left=}
	 *     (rule start) (ambiguity) {Expression_CallFunction.object=}
	 *     (rule start) (ambiguity) {Expression_CallMemberFunction.object=}
	 *     (rule start) (ambiguity) {Expression_Concatenation.left=}
	 *     (rule start) (ambiguity) {Expression_Division.left=}
	 *     (rule start) (ambiguity) {Expression_Equal.left=}
	 *     (rule start) (ambiguity) {Expression_Exponentiation.left=}
	 *     (rule start) (ambiguity) {Expression_Larger.left=}
	 *     (rule start) (ambiguity) {Expression_Larger_Equal.left=}
	 *     (rule start) (ambiguity) {Expression_Minus.left=}
	 *     (rule start) (ambiguity) {Expression_Modulo.left=}
	 *     (rule start) (ambiguity) {Expression_Multiplication.left=}
	 *     (rule start) (ambiguity) {Expression_Not_Equal.left=}
	 *     (rule start) (ambiguity) {Expression_Or.left=}
	 *     (rule start) (ambiguity) {Expression_Plus.left=}
	 *     (rule start) (ambiguity) {Expression_Smaller.left=}
	 *     (rule start) (ambiguity) {Expression_Smaller_Equal.left=}
	 */
	protected void emit_Expression_VariableName_LeftParenthesisKeyword_0_0_p(EObject semanticObject, ISynNavigable transition, List<INode> nodes) {
		acceptNodes(transition, nodes);
	}
	
	/**
	 * Ambiguous syntax:
	 *     ','?
	 *
	 * This ambiguous syntax occurs at:
	 *     parameters+=ID (ambiguity) ')' body=Block
	 *     parameters+=ID (ambiguity) varArgs?='...'
	 */
	protected void emit_Function_CommaKeyword_1_2_q(EObject semanticObject, ISynNavigable transition, List<INode> nodes) {
		acceptNodes(transition, nodes);
	}
	
	/**
	 * Ambiguous syntax:
	 *     ('{' '}')?
	 *
	 * This ambiguous syntax occurs at:
	 *     name=ID (ambiguity) (rule end)
	 */
	protected void emit_Sensor___LeftCurlyBracketKeyword_2_0_RightCurlyBracketKeyword_2_2__q(EObject semanticObject, ISynNavigable transition, List<INode> nodes) {
		acceptNodes(transition, nodes);
	}
	
}