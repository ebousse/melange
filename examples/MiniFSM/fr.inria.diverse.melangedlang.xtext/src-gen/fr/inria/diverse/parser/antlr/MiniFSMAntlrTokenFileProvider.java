/*
 * generated by Xtext 2.9.2
 */
package fr.inria.diverse.parser.antlr;

import java.io.InputStream;
import org.eclipse.xtext.parser.antlr.IAntlrTokenFileProvider;

public class MiniFSMAntlrTokenFileProvider implements IAntlrTokenFileProvider {

	@Override
	public InputStream getAntlrTokenFile() {
		ClassLoader classLoader = getClass().getClassLoader();
		return classLoader.getResourceAsStream("fr/inria/diverse/parser/antlr/internal/InternalMiniFSM.tokens");
	}
}
