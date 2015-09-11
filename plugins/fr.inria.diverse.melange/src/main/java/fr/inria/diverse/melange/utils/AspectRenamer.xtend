package fr.inria.diverse.melange.utils

import com.google.inject.Inject
import fr.inria.diverse.melange.ast.AspectExtensions
import fr.inria.diverse.melange.ast.LanguageExtensions
import fr.inria.diverse.melange.ast.MetamodelExtensions
import fr.inria.diverse.melange.metamodel.melange.Aspect
import fr.inria.diverse.melange.metamodel.melange.Language
import java.util.List
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.IWorkspace
import org.eclipse.core.resources.IWorkspaceRoot
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.emf.ecore.EClass
import org.eclipse.jdt.core.ICompilationUnit
import org.eclipse.jdt.core.IPackageFragment
import org.eclipse.jdt.core.JavaCore
import org.eclipse.jdt.core.dom.AST
import org.eclipse.jdt.core.dom.ASTParser
import org.eclipse.jdt.core.dom.ASTVisitor
import org.eclipse.jdt.core.dom.CompilationUnit
import org.eclipse.jface.text.Document
import org.eclipse.text.edits.TextEdit
import org.eclipse.xtext.naming.IQualifiedNameConverter
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.xbase.jvmmodel.JvmTypeReferenceBuilder
import org.eclipse.core.resources.IResource

class AspectRenamer {
	
	@Inject extension IQualifiedNameConverter
	@Inject extension AspectExtensions
	@Inject extension LanguageExtensions
	@Inject extension MetamodelExtensions
	@Inject extension IQualifiedNameProvider
	@Inject JvmTypeReferenceBuilder.Factory builderFactory
	
	/**
	 * Apply renaming rules on the Aspects' files generated by Kermeta3
	 */
	def void processRenaming(List<Aspect> aspects, Language l, RenamingRuleManager rulesManager){
		
		val allClasses = l.syntax.allClasses.toList
								
		val IWorkspace workspace = ResourcesPlugin.getWorkspace();
    	val IWorkspaceRoot root = workspace.getRoot();
    	val IProject[] projects = root.getProjects();
    	val targetProject = projects.findFirst[name == l.externalRuntimeName]
		val javaProject = JavaCore.create(targetProject)
		val roots = javaProject.allPackageFragmentRoots
		val src_genFolder = roots.findFirst[elementName == "xtend-gen"]
		
		val k3Patterns = convertToPattern(rulesManager)
		
		aspects.forEach[asp | 
	    	val targetAspectNamespace = l.aspectTargetNamespace
	    	val aspectNamespace = src_genFolder.getPackageFragment(targetAspectNamespace.toString)
	    	
			val targetClass = asp.aspectedClass.name
	    	val targetFqName = asp.aspectedClass.fullyQualifiedName.toString
	    	val rule = rulesManager.getClassRule(targetFqName)
	    	val newClass = 
	    		if(rule !== null){
		    		rule.value.toQualifiedName.lastSegment
	    		}
	    		else{
	    			targetClass
	    		}
			processRenaming(targetClass, newClass, aspectNamespace, rulesManager, k3Patterns, allClasses)
			
			targetProject.refreshLocal(IResource.DEPTH_INFINITE, null)
		]
	}
	
	/**
	 * Apply renaming rules on the Aspect's files generated by Kermeta3
	 */
	private def void processRenaming(String targetClass, String newClass, IPackageFragment aspectNamespace, RenamingRuleManager rulesManager, List<Pair<String,String>> k3Pattern, List<EClass> allClasses){
		
		val fileName1 = targetClass+"Aspect.java"
		val fileName2 = targetClass+"Aspect"+targetClass+"AspectContext.java"
		val fileName3 = targetClass+"Aspect"+targetClass+"AspectProperties.java"
		
		val cu1 = aspectNamespace.getCompilationUnit(fileName1)
		val cu2 = aspectNamespace.getCompilationUnit(fileName2)
		val cu3 = aspectNamespace.getCompilationUnit(fileName3)
		
		
		applyRenaming(cu1, new RenamerVisitor(rulesManager,allClasses),k3Pattern)
		applyRenaming(cu2, new RenamerVisitor(rulesManager,allClasses),k3Pattern)
		applyRenaming(cu3, new RenamerVisitor(rulesManager,allClasses),k3Pattern)
		
		cu1.rename(newClass+"Aspect.java",true,null)
		cu2.rename(newClass+"Aspect"+newClass+"AspectContext.java",true,null)
		cu3.rename(newClass+"Aspect"+newClass+"AspectProperties.java",true,null)
	}
	
	/**
	 * Visit {@link sourceUnit} with {@link renamer} and apply changes in
	 * the corresponding textual file.
	 */
	private def void applyRenaming(ICompilationUnit sourceUnit, ASTVisitor renamer, List<Pair<String,String>> k3pattern){
		
		// textual document
		val String source = sourceUnit.getSource();
		val Document document= new Document(source);
		
		// get the AST
		val ASTParser parser = ASTParser.newParser(AST.JLS8)
		parser.setSource(sourceUnit)
//		parser.setResolveBindings(true) --not working
		val astRoot = parser.createAST(null) as CompilationUnit
		
		// start record of the modifications
		astRoot.recordModifications()
	
		astRoot.accept(renamer)
		
		// computation of the text edits
	   	val TextEdit edits = astRoot.rewrite(document, sourceUnit.getJavaProject().getOptions(true))
	
	   	// computation of the new source code
	   	edits.apply(document);
	   	var String newSource = document.get()
		newSource = newSource.replacePatterns(k3pattern)
	
	   	// update of the compilation unit
	   	sourceUnit.getBuffer().setContents(newSource)
	   	sourceUnit.getBuffer().save(null,true)
		
	}
	
	/**
	 * Rename AspectContext & AspectProperties in fileContent when exist a renaming rule for their base Class
	 */
	private def String replacePatterns(String fileContent, List<Pair<String,String>> patternRules){
		val StringBuilder newContent = new StringBuilder(fileContent)
		for(rule : patternRules){
			val oldPattern = rule.key
			val newPattern = rule.value
			newContent.replaceAll(oldPattern,newPattern)
		}
		return newContent.toString
	}
	
	/**
	 * Deduce k3's Aspect patterns from {@link rulesManager} and associated replacement patterns
	 */
	private def List<Pair<String,String>> convertToPattern(RenamingRuleManager rulesManager){
		val res = newArrayList
		rulesManager.allClassRules.forEach[rule |
			val oldClassName =  rule.key.substring( rule.key.lastIndexOf(".")+1)
			val newClassName =  rule.value.substring( rule.value.lastIndexOf(".")+1)
			val oldPattern = oldClassName+"Aspect"
			val newPattern = newClassName+"Aspect"
			res.add(oldPattern+oldPattern+"Context" -> newPattern+newPattern+"Context") //order matter since first pattern is replaced
			res.add(oldPattern+oldPattern+"Properties" -> newPattern+newPattern+"Properties")
			res.add(oldPattern -> newPattern)
		]
		return res
	}
	
	private def replaceAll(StringBuilder string, String oldPattern, String newPattern){
		val oldPatternSize = oldPattern.length
		val newPatternSize = newPattern.length
		
		var startIndex = 0
		var index = string.indexOf(oldPattern)
		while(index != -1){
			val previousChar = string.charAt(index - 1)
			val followingChar = string.charAt(index + oldPatternSize)
			if(!Character.isJavaIdentifierPart(previousChar) && !Character.isJavaIdentifierPart(followingChar)){
				string.replace(index, index+oldPatternSize, newPattern)
				startIndex = index + newPatternSize
			}
			else{
				startIndex = index + oldPatternSize
			}
			index = string.indexOf(oldPattern, startIndex)
		}
	}
}
