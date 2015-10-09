package fr.inria.diverse.melange.jvmmodel

import com.google.inject.Inject
import fr.inria.diverse.melange.adapters.EListAdapter
import fr.inria.diverse.melange.adapters.EObjectAdapter
import fr.inria.diverse.melange.ast.AspectExtensions
import fr.inria.diverse.melange.ast.LanguageExtensions
import fr.inria.diverse.melange.ast.MetamodelExtensions
import fr.inria.diverse.melange.ast.ModelTypeExtensions
import fr.inria.diverse.melange.ast.NamingHelper
import fr.inria.diverse.melange.lib.EcoreExtensions
import fr.inria.diverse.melange.lib.MappingExtensions
import fr.inria.diverse.melange.metamodel.melange.Aspect
import fr.inria.diverse.melange.metamodel.melange.Mapping
import fr.inria.diverse.melange.metamodel.melange.Metamodel
import fr.inria.diverse.melange.metamodel.melange.ModelType
import fr.inria.diverse.melange.utils.AspectToEcore
import fr.inria.diverse.melange.utils.TypeReferencesHelper
import org.eclipse.emf.common.util.EMap
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EEnum
import org.eclipse.emf.ecore.EOperation
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.common.types.JvmDeclaredType
import org.eclipse.xtext.common.types.JvmGenericType
import org.eclipse.xtext.common.types.JvmOperation
import org.eclipse.xtext.common.types.JvmParameterizedTypeReference
import org.eclipse.xtext.common.types.JvmTypeReference
import org.eclipse.xtext.common.types.JvmVisibility
import org.eclipse.xtext.common.types.TypesFactory
import org.eclipse.xtext.util.internal.Stopwatches
import org.eclipse.xtext.xbase.jvmmodel.IJvmDeclaredTypeAcceptor
import org.eclipse.xtext.xbase.jvmmodel.JvmAnnotationReferenceBuilder
import org.eclipse.xtext.xbase.jvmmodel.JvmTypeReferenceBuilder
import org.eclipse.xtext.xbase.jvmmodel.JvmTypesBuilder
import fr.inria.diverse.melange.adapters.MockAdapter
import org.eclipse.emf.common.util.EList

/**
 * This class generates a Java class that implements an Object type for a Metaclass.
 */
class MetaclassAdapterInferrer
{
	@Inject extension JvmModelInferrerHelper
	@Inject extension JvmTypesBuilder
	@Inject extension NamingHelper
	@Inject extension ModelTypeExtensions
	@Inject extension AspectExtensions
	@Inject extension MetamodelExtensions
	@Inject extension LanguageExtensions
	@Inject extension EcoreExtensions
	@Inject extension AspectToEcore
	@Inject extension MelangeTypesBuilder
	@Inject extension TypeReferencesHelper
	@Inject extension JvmAnnotationReferenceBuilder.Factory jvmAnnotationReferenceBuilderFactory
	@Inject extension MappingExtensions
	extension JvmAnnotationReferenceBuilder jvmAnnotationReferenceBuilder
	extension JvmTypeReferenceBuilder typeRefBuilder

	/**
	 * Creates a Java class that implements an Object type from {@link superType} and delegates operations
	 * to {@link cls}. (Adapter design  pattern)
	 *
	 * @param mm
	 * @param superType Model type implemented by {@link mm}
	 * @param cls Metaclass corresponding to an Object type in {@link superType}
	 * @param acceptor
	 * @param builder
	 */
	def void generateAdapter(Metamodel mm, ModelType superType, EClass cls, IJvmDeclaredTypeAcceptor acceptor, extension JvmTypeReferenceBuilder builder) {
		typeRefBuilder = builder
		jvmAnnotationReferenceBuilder = jvmAnnotationReferenceBuilderFactory.create(mm.eResource.resourceSet)
		val task = Stopwatches.forTask("generate metaclass adapters")
		task.start

		val mapping = mm.owningLanguage.mappings.findFirst[to == superType]
		val mmCls = mm.allClasses.findFirst[mapping.namesMatch(it, cls)]

		acceptor.accept(mm.toClass(mm.adapterNameFor(superType, cls)))
		[jvmCls |
			cls.ETypeParameters.forEach[p |
				jvmCls.typeParameters += TypesFactory::eINSTANCE.createJvmTypeParameter => [name = p.name]
			]

			if(cls.isAspectSpecific){
				jvmCls.superTypes += MockAdapter.typeRef(mm.typeRef(mmCls, #[jvmCls]))
				
				cls.EAllOperations.sortByOverridingPriority.filter[!hasSuppressedVisibility].forEach[processOperation(mm, superType, jvmCls)]
				cls.EAllAttributes.forEach[processAttribute(mmCls, mm, superType, mapping, jvmCls)]
				cls.EAllReferences.forEach[processReference(mmCls, mm, superType, mapping, jvmCls)]
			}
			else{
				jvmCls.superTypes += EObjectAdapter.typeRef(mm.typeRef(mmCls, #[jvmCls]))
				
				jvmCls.members += mm.toConstructor[
					body = '''
						super(«mm.getAdaptersFactoryNameFor(superType)».getInstance()) ;
					'''
				]
				cls.EAllOperations.sortByOverridingPriority.filter[!hasSuppressedVisibility && !isAspectSpecific].forEach[processOperation(mm, superType, jvmCls)]
				mm.owningLanguage.findAspectsOn(cls).toList.sortByOverridingPriority.forEach[processAspect(mm, superType, jvmCls)]
				cls.EAllAttributes.filter[!isAspectSpecific].forEach[processAttribute(mmCls, mm, superType, mapping, jvmCls)]
				cls.EAllReferences.filter[!isAspectSpecific].forEach[processReference(mmCls, mm, superType, mapping, jvmCls)]
			}
			
			jvmCls.superTypes += superType.typeRef(cls, #[jvmCls])

			// TODO: Generic super types
			cls.EGenericSuperTypes.forEach[sup |]

			// TODO: Type parameters
			cls.ETypeParameters.forEach[p |]

			jvmCls.members += mm.toField("adaptersFactory", mm.getAdaptersFactoryNameFor(superType).typeRef)

			// TODO: Also override eAllContents() to perform adaptation

			
		]

		task.stop
	}

	/**
	 * Creates accessors/mutators for attribute {@link attr} and add them to {@link jvmCls}
	 */
	private def void processAttribute(EAttribute attr, EClass mmCls, Metamodel mm, ModelType superType, Mapping mapping, JvmGenericType jvmCls) {
		val attrType = superType.typeRef(attr, #[jvmCls])
		val mmAttr = mapping.findCorrespondingFeature(mmCls, attr)

		jvmCls.members += mm.toMethod(attr.getterName, attrType)[
			annotations += Override.annotationRef

			if (attr.EType instanceof EEnum)
				body = '''
					return «superType.getFqnFor(attr.EType)».get(adaptee.«mmAttr.getterName»().getValue());
				'''
			else if (mmCls.isAspectSpecific){
				body = '''
					throw new UnsupportedOperationException("It's a mock") ;
				'''
			}
			else
				body = '''
					return adaptee.«mmAttr.getterName»() ;
				'''
		]

		if (attr.needsSetter) {
			jvmCls.members += mm.toMethod(attr.setterName, Void::TYPE.typeRef)[
				annotations += Override.annotationRef
				parameters += mm.toParameter("o", attrType)

				if (attr.EType instanceof EEnum)
					body = '''
						adaptee.«mmAttr.setterName»(«mm.getFqnFor(superType, attr.EType)».get(o.getValue())) ;
					'''
				else if (mmCls.isAspectSpecific){
					body = '''
						throw new UnsupportedOperationException("It's a mock") ;
					'''
				}
				else
					body = '''
						adaptee.«mmAttr.setterName»(o) ;
					'''
			]
		}

		if (attr.needsUnsetter)
			jvmCls.members += mm.toUnsetter(attr)

		if (attr.needsUnsetterChecker)
			jvmCls.members += mm.toUnsetterCheck(attr)
	}

	/**
	 * Creates accessors/mutators for references defined in {@link cls} and add them to {@link jvmCls}
	 */
	private def void processReference(EReference ref, EClass mmCls, Metamodel mm, ModelType superType, Mapping mapping, JvmGenericType jvmCls) {
		val refType = superType.typeRef(ref, #[jvmCls])
		val adapName = mm.adapterNameFor(superType, ref.EReferenceType)
		val mmRef = mapping.findCorrespondingFeature(mmCls, ref)

		if (ref.isEMFMapDetails) // Special case: EMF Map$Entry
			jvmCls.members += mm.toMethod("getDetails", EMap.typeRef(String.typeRef, String.typeRef))[
				body = '''return adaptee.getDetails() ;'''
			]
		else
			jvmCls.members += mm.toMethod(ref.getterName, refType)[
				annotations += Override.annotationRef

				if (mmCls.isAspectSpecific){
					body = '''
						throw new UnsupportedOperationException("It's a mock") ;
					'''
				}
				else{
					body = '''
						«IF mm.owningLanguage.hasAdapterFor(superType, ref.EReferenceType)»
							«IF ref.many»
								return «EListAdapter».newInstance(adaptee.«mmRef.getterName»(), «adapName».class) ;
							«ELSE»
								return adaptersFactory.create«mm.simpleAdapterNameFor(superType, ref.EReferenceType)»(adaptee.«mmRef.getterName»()) ;
							«ENDIF»
						«ELSE»
							return adaptee.«mmRef.getterName»();
						«ENDIF»
					'''
				}
			]

		if (ref.needsSetter) {
			jvmCls.members += mm.toMethod(ref.setterName, Void::TYPE.typeRef)[
				annotations += Override.annotationRef
				parameters += mm.toParameter("o", refType)

				if (mmCls.isAspectSpecific){
					body = '''
						throw new UnsupportedOperationException("It's a mock") ;
					'''
				}
				else{
					body = '''
						adaptee.«mmRef.setterName»(((«adapName») o).getAdaptee()) ;
					'''
				}
			]
		}

		if (ref.needsUnsetter)
			jvmCls.members += mm.toUnsetter(ref)

		if (ref.needsUnsetterChecker)
			jvmCls.members += mm.toUnsetterCheck(ref)
	}

	/**
	 * Creates proxy methods for each operations defined in {@link cls} and add them to {@link jvmCls}.
	 */
	private def void processOperation(EOperation op, Metamodel mm, ModelType superType, JvmGenericType jvmCls) {
		val opName = if (!op.EContainingClass.EPackage.isUml) op.name else op.formatUmlOperationName

		val newOp = mm.toMethod(opName, null)[m |
			m.annotations += Override.annotationRef

			val paramsList = new StringBuilder

			op.ETypeParameters.forEach[t |
				m.typeParameters += TypesFactory.eINSTANCE.createJvmTypeParameter => [tp |
					tp.name = t.name
				]
			]

			op.ETypeParameters.forEach[t |
				t.EBounds
				.forEach[b |
					val tp = m.typeParameters.findFirst[name == t.name]

					if (b.EClassifier !== null)
						tp.constraints += TypesFactory.eINSTANCE.createJvmUpperBound => [
							typeReference = superType.typeRef(b, #[m, jvmCls])
						]
					else if (b.ETypeParameter !== null)
						tp.constraints += TypesFactory.eINSTANCE.createJvmUpperBound => [
							typeReference = createTypeParameterReference(#[m, jvmCls], b.ETypeParameter.name)
						]
				]
			]

			paramsList.append('''«FOR p : op.EParameters SEPARATOR ","»
				«IF p.EType instanceof EClass && mm.owningLanguage.hasAdapterFor(superType, p.EType)»
					«IF p.many»
						((«EListAdapter») «p.name»).getAdaptee()
					«ELSE»
						((«mm.adapterNameFor(superType, p.EType as EClass)») «p.name»).getAdaptee()
					«ENDIF»
				«ELSEIF p.EType instanceof EEnum»
					«mm.getFqnFor(superType, p.EType)».get(«p.name».getValue())
				«ELSE»
					«p.name»
				«ENDIF»«ENDFOR»
			''')

			op.EParameters.forEach[p | m.parameters += mm.toParameter(p.name, superType.typeRef(p, #[m, jvmCls]))]

			// TODO: Manage exceptions
			op.EExceptions.forEach[e |
				m.exceptions += typeRef(if (e.instanceClass !== null) e.instanceClass.name else e.instanceTypeName)
			]

			// TODO: Manage generic exceptions
			op.EGenericExceptions.forEach[e |]

			if (op.EContainingClass.isAspectSpecific){
				m.body = '''
					throw new UnsupportedOperationException("It's a mock") ;
				'''
			}
			else{
				m.body = '''
					«IF op.EType instanceof EClass && mm.owningLanguage.hasAdapterFor(superType, op.EType)»
						«IF op.many»
							return «EListAdapter».newInstance(adaptee.«opName»(«paramsList»), «mm.adapterNameFor(superType, op.EType as EClass)».class) ;
						«ELSE»
							return adaptersFactory.create«mm.simpleAdapterNameFor(superType, op.EType as EClass)»(adaptee.«opName»(«paramsList»)) ;
						«ENDIF»
					«ELSEIF op.EType !== null»
						return adaptee.«opName»(«paramsList») ;
					«ELSE»
						adaptee.«opName»(«paramsList») ;
					«ENDIF»
				'''
			}
		]

		newOp.returnType = superType.typeRef(op, #[newOp, jvmCls])
		jvmCls.members += newOp
	}

	/**
	 * Creates methods for operations defined in aspects and add them to {@link jvmCls}.
	 */
	private def void processAspect(Aspect aspect, Metamodel mm, ModelType superType, JvmGenericType jvmCls) {
		// At this stage, we have to link to the *actual* aspect to be used
		// i.e. the one that may have been "type-group-transformed"
		// (which means we assume it exists/has been generated/is a JvmDeclaredType)
		if (!(aspect.aspectTypeRef?.type instanceof JvmDeclaredType))
			return;

		val oldRef = aspect.aspectTypeRef
		aspect.aspectTypeRef =
			if (!aspect.aspectTypeRef.isDefinedOver(mm))
				typeRef(
					'''«mm.owningLanguage.aspectTargetNamespace».«aspect.aspectTypeRef.simpleName»'''
				)
			else
				oldRef

		val aspType = aspect.aspectTypeRef.type
		if (aspType !== null)
			if (aspType instanceof JvmDeclaredType)
				aspType.declaredOperations
				.filter[op |
					   !op.simpleName.startsWith("_privk3")
					&& !op.simpleName.startsWith("super_")
					//&& op.parameters.head?.name == "_self"
					&& !jvmCls.members.filter(JvmOperation).exists[opp | op.matchSignature(opp)]
					&& op.visibility == JvmVisibility.PUBLIC
				]
				.forEach[processAspectOperation(aspect, mm, superType, jvmCls)]

		aspect.aspectTypeRef = oldRef
	}

	private def void processAspectOperation(JvmOperation op, Aspect aspect, Metamodel mm, ModelType superType, JvmGenericType jvmCls) {
		val asp = aspect.aspectTypeRef.type as JvmDeclaredType
		val paramsList = new StringBuilder
		val featureName = asp.findFeatureNameFor(op)
		val realType =
			if (op.returnType.isCollection)
				(op.returnType as JvmParameterizedTypeReference).arguments.head.type.simpleName
			else
				op.returnType.simpleName
		val mtCls =
			if (op.returnType.isCollection)
				superType.findClass(realType)
			else
				superType.findClass(realType)
		val retType =
			if (op.returnType.simpleName == "void")
				typeRef(Void.TYPE)
			else if (mtCls !== null)
				if (op.returnType.isCollection){
					EList.typeRef(superType.typeRef(mtCls, #[jvmCls]))
				}
				else
					superType.typeRef(mtCls, #[jvmCls])
			else if (op.returnType.isCollection){
				EList.typeRef((op.returnType as JvmParameterizedTypeReference).arguments.head.qualifiedName.typeRef)
			}
			else
				op.returnType.qualifiedName.typeRef

		paramsList.append("adaptee")
		op.parameters.drop(1).forEach[p, i |
			val realTypeP =
				if (p.parameterType.isCollection)
					(p.parameterType as JvmParameterizedTypeReference).arguments.head.type.simpleName
				else
					p.parameterType.simpleName

			paramsList.append('''
				«IF mm.owningLanguage.hasAdapterFor(superType, p.parameterType.simpleName)»
					, ((«mm.adapterNameFor(superType, p.parameterType.simpleName)») «p.name»).getAdaptee()
				«ELSEIF p.parameterType.isCollection && mm.owningLanguage.hasAdapterFor(superType, realTypeP)»
					, ((«EListAdapter») «p.name»).getAdaptee()
				«ELSE»
					, «p.name»
				«ENDIF»
			''')
		]

		val opName =
			if (featureName === null) op.simpleName
			else if (op.parameters.size == 1) op.getterName
			else op.setterName
		val correspondingCls = superType.findClass(aspect.aspectedClass.name)

		// If the super type doesn't expose this method, we don't need to generate it
		val correspondingFeature = correspondingCls.EAllStructuralFeatures.findFirst[name == featureName]
		val isSetter = correspondingFeature !== null && op.parameters.size == 2
		if (
			(correspondingFeature !== null || correspondingCls.EAllOperations.exists[name == opName])
			&&
			(!isSetter || correspondingFeature.needsSetter)
		)
		{
			jvmCls.members += mm.toMethod(opName, retType)[
				annotations += Override.annotationRef

				op.parameters.drop(1).forEach[p |
					val realTypeP =
						if (p.parameterType.isCollection)
							(p.parameterType as JvmParameterizedTypeReference).arguments.head.type.simpleName
						else
							p.parameterType.simpleName
					val pCls = superType.findClassifier(realTypeP)
					val pType =
						if (pCls !== null)
							if (p.parameterType.isCollection){
								EList.typeRef(superType.typeRef(pCls, #[jvmCls]))
							}
							else
								superType.typeRef(pCls, #[jvmCls])
						else
							p.parameterType.qualifiedName.typeRef

					parameters += mm.toParameter(p.name, pType)
				]

				body = '''
					«IF retType.isValidReturnType»
						«IF mm.owningLanguage.hasAdapterFor(superType, realType)»
							«IF op.returnType.isCollection»
								return «EListAdapter».newInstance(«asp.qualifiedName».«op.simpleName»(«paramsList»), «mm.adapterNameFor(superType, realType)».class) ;
							«ELSE»
								return adaptersFactory.create«mm.simpleAdapterNameFor(superType, realType)»(«asp.qualifiedName».«op.simpleName»(«paramsList»)) ;
							«ENDIF»
						«ELSE»
							return «asp.qualifiedName».«op.simpleName»(«paramsList») ;
						«ENDIF»
					«ELSE»
						«asp.qualifiedName».«op.simpleName»(«paramsList») ;
					«ENDIF»
				'''
			]
		}
	}

	private def boolean isValidReturnType(JvmTypeReference ref) {
		return ref.type !== null && ref.type.simpleName != "void" && ref.type.simpleName != "null"
	}

	private def Iterable<Aspect> sortByOverridingPriority(Iterable<Aspect> aspects) {
		return aspects.sortWith[aspA, aspB |
			val clsA = aspA.aspectedClass
			val clsB = aspB.aspectedClass

			if (clsA.EAllSuperTypes.contains(clsB))
				return -1
			else if (clsB.EAllSuperTypes.contains(clsA))
				return 1
			else return 0
		]
	}
	
	/**
	 * Return true if both operations have exactly the same signature.
	 * (comparing types' simple name)
	 * 
	 * @op1 Method from Aspect
	 * @op2 Method from Adapter
	 */
	def private boolean matchSignature(JvmOperation op1, JvmOperation op2){
		val matchName = op1.simpleName == op2.simpleName
		val matchReturn = op1.returnType.simpleName == op2.returnType.simpleName
		val matchParams = 
			op1.parameters.size-1 == op2.parameters.size &&
			op1.parameters.drop(1).forall[p1|
				val pos = op1.parameters.indexOf(p1) - 1
				val p1Type = p1.parameterType
				val p2Type = op2.parameters.get(pos).parameterType
				return p1Type.simpleName == p2Type.simpleName
			]
		
		return matchName && matchParams && matchReturn
	}

	/*def boolean +=(EList<JvmMember> members, JvmOperation m) {
		if (!members.filter(JvmOperation).exists[overrides(m)])
			members += (m as JvmMember)

		return false
	}*/
}
