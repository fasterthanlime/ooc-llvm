use llvm
import structs/ArrayList

LLVMLinkInJIT: extern func

// Modules
LContext: cover from LLVMContextRef {
    new: extern(LLVMContextCreate) static func -> This

    getGlobal: extern(LLVMGetGlobalContext) static func -> This

    dispose: extern(LLVMContextDispose) func

    // Types
    float_:    extern(LLVMFloatTypeInContext)   func -> LValue
    double_:   extern(LLVMDoubleTypeInContext)  func -> LValue
    xf86_fp80: extern(LLVMX86FP80TypeInContext)  func -> LValue
    fp128:     extern(LLVMFP128TypeInContext)    func -> LValue
    ppc_fp128: extern(LLVMPPCFP128TypeInContext) func -> LValue

    struct_: extern(LLVMStructTypeInContext) func (elementTypes: LType*, elementCount: UInt, isPacked: Int) -> LValue

    void_:  extern(LLVMVoidTypeInContext)  func -> LValue
    label:  extern(LLVMLabelTypeInContext)  func -> LValue
    opaque: extern(LLVMOpaqueTypeInContext) func -> LValue
}

LModule: cover from LLVMModuleRef {
    new: extern(LLVMModuleCreateWithName)          static func (CString) -> This
    new: extern(LLVMModuleCreateWithNameInContext) static func ~inContext (CString, LContext) -> This

    dispose: extern(LLVMDisposeModule) func

    getDataLayout: extern(LLVMGetDataLayout) func -> CString
    setDataLayout: extern(LLVMSetDataLayout) func (triple: CString)

    getTarget: extern(LLVMGetTarget) func -> CString
    setTarget: extern(LLVMSetTarget) func (triple: CString)

    addTypeName:    extern(LLVMAddTypeName)    func (name: CString, LType)
    deleteTypeName: extern(LLVMDeleteTypeName) func (name: CString)
    getTypeByName:  extern(LLVMGetTypeByName)  func (name: CString) -> LType

    dump: extern(LLVMDumpModule) func

    addFunction: func (name: String, functionType: LType) -> Function {
        Function new(this, name, functionType)
    }

    addFunction: func ~withRetAndArgs (name: String, ret: LType, arguments: LType[]) -> Function {
        Function new(this, name, LType function(ret, arguments))
    }

    addFunction: func ~withRetAndArgsWithName (name: String, ret: LType,
             arguments: LType[], argNames: String[]) -> Function {
        fn := Function new(this, name, LType function(ret, arguments))
        fnArgs := fn args
        for(i in 0..argNames length) {
            fnArgs[i] setName(argNames[i])
        }
        fn
    }

    getFunction: extern(LLVMGetNamedFunction) func (name: CString) -> Function

    writeBitcode: extern(LLVMWriteBitcodeToFile)       func ~toFile (path: CString) -> Int
    writeBitcode: extern(LLVMWriteBitcodeToFD)         func ~toFD (fd, shouldClose, unbuffered: Int) -> Int
    writeBitcode: extern(LLVMWriteBitcodeToFileHandle) func ~toFileHandle (handle: Int) -> Int
}

// Types
LType: cover from LLVMTypeRef {
    // Integer types
    int1:  extern(LLVMInt1Type)  static func -> This
    int8:  extern(LLVMInt8Type)  static func -> This
    int16: extern(LLVMInt16Type) static func -> This
    int32: extern(LLVMInt32Type) static func -> This
    int64: extern(LLVMInt64Type) static func -> This
    int_:  extern(LLVMIntType)   static func (numBits: UInt) -> This
    getIntTypeWidth: extern(LLVMGetIntTypeWidth) func -> UInt

    // Real types
    float_:    extern(LLVMFloatType)    static func -> This
    double_:   extern(LLVMDoubleType)   static func -> This
    x86_fp80:  extern(LLVMX86FP80Type)  static func -> This
    fp128:     extern(LLVMFP128Type)    static func -> This
    ppc_fp128: extern(LLVMPPCFP128Type) static func -> This

    // Function types
    function: extern(LLVMFunctionType) static func (returnType: This,
        paramTypes: This*, paramCount: UInt, varArg?: Bool) -> This

    function: static func ~voidArgs (returnType: This) -> This {
        function(returnType, null, 0, false)
    }

    function: static func ~withArray (returnType: This, paramTypes: This[], varArg? := false) -> This {
        function(returnType, paramTypes data, paramTypes length, varArg?)
    }

    function: static func ~withArrayList (returnType: This, paramTypes: ArrayList<This>, varArg? := false) -> This {
        function(returnType, paramTypes toArray() as This*, paramTypes size as UInt, varArg?)
    }

    isFunctionVarArg: extern(LLVMIsFunctionVarArg) func -> Int
    getReturnType:    extern(LLVMGetReturnType)    func -> This
    countParamTypes:  extern(LLVMCountParamTypes)  func -> UInt
    getParamTypes:    extern(LLVMGetParamTypes)    func (dest: This*)

    // Struct types
    struct_: extern(LLVMStructType) static func (elementTypes: This*, elementCount: UInt, packed?: Int) -> This
    struct_: static func ~withArray (elementTypes: This[], packed?: Bool) -> This {
        struct_(elementTypes data, elementTypes length, packed? as Int)
    }
    struct_: static func ~withArrayUnpacked (elementTypes: This[]) -> This {
        struct_(elementTypes, false)
    }
    countStructElementTypes: extern(LLVMCountStructElementTypes) func -> UInt
    getStructElementTypes:   extern(LLVMGetStructElementTypes)   func (dest: This*)
    isPackedStruct:          extern(LLVMIsPackedStruct)          func -> Int

    // Array, pointer, and vector types (sequence types)
    array:   extern(LLVMArrayType)   static func (elementType: This, elementCount: UInt) -> This
    pointer: extern(LLVMPointerType) static func (elementType: This, addressSpace: UInt) -> This
    pointer: static func ~withoutAddressSpace (elementType: This) -> This {
        pointer(elementType, 0)
    }
    vector:  extern(LLVMVectorType)  static func (elementType: This, elementCount: UInt) -> This

    getElementType:         extern(LLVMGetElementType)         func -> This
    getArrayLength:         extern(LLVMGetArrayLength)         func -> UInt
    getPointerAddressSpace: extern(LLVMGetPointerAddressSpace) func -> UInt
    getVectorSize:          extern(LLVMGetVectorSize)          func -> UInt

    // Other types
    void_:  extern(LLVMVoidType)   static func -> This
    label:  extern(LLVMLabelType)  static func -> This
    opaque: extern(LLVMOpaqueType) static func -> This

    // Constants
    constNull:        extern(LLVMConstNull)        func -> LValue
    constAllOnes:     extern(LLVMConstAllOnes)     func -> LValue
    getUndef:         extern(LLVMGetUndef)         func -> LValue
//    constant?:        extern(LLVMIsConstant)       func -> Bool
//    null?:            extern(LLVMIsNull)           func -> Bool
//    undef?:           extern(LLVMIsUndef)          func -> Bool
    constPointerNull: extern(LLVMConstPointerNull) func -> LValue

    // Scalar constants
    
}

LValue: cover from LLVMValueRef {
    type:    extern(LLVMTypeOf)       func -> LType
    getName: extern(LLVMGetValueName) func -> CString
    setName: extern(LLVMSetValueName) func (CString)
    dump:    extern(LLVMDumpValue)    func

    constPointerNull: extern(LLVMConstPointerNull) static func (LType) -> This
    constInt: extern(LLVMConstInt) static func (LType, ULLong, Bool) -> This
    constInt: static func ~signed (ty: LType, val: ULLong) -> This {
        constInt(ty, val, true)
    }
    constInt: extern(LLVMConstIntOfStringAndSize) static func ~cstring (LType, CString, UInt, UInt8) -> This
    constInt: static func ~string (ty: LType, str: String, radix: UInt8) -> This {
        constInt(ty, str toCString(), str size, radix)
    }
    constReal: extern(LLVMConstReal) static func (LType, Double) -> This
    constReal: extern(LLVMConstRealOfStringAndSize) static func ~cstring (LType, CString, UInt) -> This
    constReal: static func ~string (ty: LType, str: String) -> This {
        constReal(ty, str toCString(), str size)
    }
    constString: extern(LLVMConstString) static func (CString, UInt, Bool) -> This
    constString: static func ~string (str: String, dontNullTerminate? := false) -> This {
        constString(str toCString(), str size, dontNullTerminate?)
    }
    constArray: extern(LLVMConstArray) static func (LType, LValue*, UInt) -> This
    constArray: static func ~withArray (elemTy: LType, constVals: LValue[]) -> This {
        constArray(elemTy, constVals data, constVals length)
    }
    constStruct: extern(LLVMConstStruct) static func (LValue*, UInt, Bool) -> This
    constStruct: static func ~withArray (constVals: LValue[], packed? := false) -> This {
        constStruct(constVals data, constVals length, packed?)
    }
    constVector: extern(LLVMConstVector) static func (LValue*, UInt) -> This
    constVector: static func ~withArray (scalarConstVals: LValue[]) -> This {
        constVector(scalarConstVals data, scalarConstVals length)
    }
}

LLVMGetFirstParam: extern func (Function) -> LValue
LLVMGetNextParam:  extern func (LValue) -> LValue

Function: cover from LValue {
    new: extern(LLVMAddFunction) static func (module: LModule, name: CString, functionType: LType) -> This

    appendBasicBlock: extern(LLVMAppendBasicBlock) func (CString) -> BasicBlock

    builder: func -> Builder {
        appendBasicBlock("entry") builder()
    }

    build: func (fn: Func (Builder, ArrayList<LValue>)) {
        fn(builder(), args)
    }

    args: ArrayList<LValue> {
        get {
            argsList := ArrayList<LValue> new()
            param := LLVMGetFirstParam(this)

            while(param != null) {
                argsList add(param)
                param = LLVMGetNextParam(param)
            }

            argsList
        }
    }
}

BasicBlock: cover from LLVMBasicBlockRef {
    builder: func -> Builder {
        Builder new(this)
    }
}

Builder: cover from LLVMBuilderRef {
    new: extern(LLVMCreateBuilder)          static func -> This
    new: extern(LLVMCreateBuilderInContext) static func ~inContext (LContext) -> This

    new: static func ~atEnd (basicBlock: BasicBlock) -> This {
        builder := This new()
        builder positionAtEnd(basicBlock)
        builder
    }

    position:               extern(LLVMPositionBuilder)           func (BasicBlock, LValue)
    positionBefore:         extern(LLVMPositionBuilderBefore)     func (LValue)
    positionAtEnd:          extern(LLVMPositionBuilderAtEnd)      func (BasicBlock)
    getInsertBlock:         extern(LLVMGetInsertBlock)            func -> BasicBlock
    clearInsertionPosition: extern(LLVMClearInsertionPosition)    func
    insert:                 extern(LLVMInsertIntoBuilder)         func (LValue)
    insert:                 extern(LLVMInsertIntoBuilderWithName) func ~withName (LValue, CString)

    dispose: extern(LLVMDisposeBuilder) func

    // Terminator instructions
    ret: extern(LLVMBuildRetVoid)      func ~void -> LValue
    ret: extern(LLVMBuildRet)          func (LValue) -> LValue
    ret: extern(LLVMBuildAggregateRet) func ~aggregate (LValue*, UInt) -> LValue
    
    br: extern(LLVMBuildBr)     func (dest: BasicBlock) -> LValue
    br: extern(LLVMBuildCondBr) func ~cond (cond: LValue, iftrue: BasicBlock, iffalse: BasicBlock) -> LValue
    
    switch: extern(LLVMBuildSwitch) func (val: LValue, elseBlock: BasicBlock, numCases: UInt) -> LValue
    invoke: extern(LLVMBuildInvoke) func (fn: LValue, args: LValue*, numArgs: UInt, thenBlock: BasicBlock, catchBlock: BasicBlock, name: CString) -> LValue

    unwind:      extern(LLVMBuildUnwind)      func -> LValue
    unreachable: extern(LLVMBuildUnreachable) func -> LValue

    // Add a case to the switch instruction
    addCase: extern(LLVMAddCase) static func (switchInstr: LValue, onVal: LValue, dest: BasicBlock)

    // Arithmetic instructions
    add:       extern(LLVMBuildAdd)       func (lhs, rhs: LValue, name: CString) -> LValue
    addNSW:    extern(LLVMBuildNSWAdd)    func (lhs, rhs: LValue, name: CString) -> LValue
    fadd:      extern(LLVMBuildFAdd)      func (lhs, rhs: LValue, name: CString) -> LValue
    sub:       extern(LLVMBuildSub)       func (lhs, rhs: LValue, name: CString) -> LValue
    fsub:      extern(LLVMBuildFSub)      func (lhs, rhs: LValue, name: CString) -> LValue
    mul:       extern(LLVMBuildMul)       func (lhs, rhs: LValue, name: CString) -> LValue
    fmul:      extern(LLVMBuildFMul)      func (lhs, rhs: LValue, name: CString) -> LValue
    udiv:      extern(LLVMBuildUDiv)      func (lhs, rhs: LValue, name: CString) -> LValue
    sdiv:      extern(LLVMBuildSDiv)      func (lhs, rhs: LValue, name: CString) -> LValue
    sdivExact: extern(LLVMBuildExactSDiv) func (lhs, rhs: LValue, name: CString) -> LValue
    fdiv:      extern(LLVMBuildFDiv)      func (lhs, rhs: LValue, name: CString) -> LValue
    urem:      extern(LLVMBuildURem)      func (lhs, rhs: LValue, name: CString) -> LValue
    srem:      extern(LLVMBuildSRem)      func (lhs, rhs: LValue, name: CString) -> LValue
    frem:      extern(LLVMBuildFRem)      func (lhs, rhs: LValue, name: CString) -> LValue
    shl:       extern(LLVMBuildShl)       func (lhs, rhs: LValue, name: CString) -> LValue
    lshr:      extern(LLVMBuildLShr)      func (lhs, rhs: LValue, name: CString) -> LValue
    ashr:      extern(LLVMBuildAShr)      func (lhs, rhs: LValue, name: CString) -> LValue
    and:       extern(LLVMBuildAnd)       func (lhs, rhs: LValue, name: CString) -> LValue
    or:        extern(LLVMBuildOr)        func (lhs, rhs: LValue, name: CString) -> LValue
    xor:       extern(LLVMBuildXor)       func (lhs, rhs: LValue, name: CString) -> LValue
    neg:       extern(LLVMBuildNeg)       func (val: LValue, name: CString) -> LValue
    not:       extern(LLVMBuildNot)       func (val: LValue, name: CString) -> LValue

    // Memory instructions
    malloc:      extern(LLVMBuildMalloc)      func (LType, CString) -> LValue
    alloca:      extern(LLVMBuildAlloca)      func (LType, CString) -> LValue
    arrayMalloc: extern(LLVMBuildArrayMalloc) func (LType, LValue, CString) -> LValue
    arrayAlloca: extern(LLVMBuildArrayMalloc) func (LType, LValue, CString) -> LValue

    free:  extern(LLVMBuildFree)  func (pointer: LValue) -> LValue
    load:  extern(LLVMBuildLoad)  func (pointer: LValue, name: CString) -> LValue
    store: extern(LLVMBuildStore) func (val: LValue, ptr: LValue) -> LValue

    gep:         extern(LLVMBuildGEP)         func (ptr: LValue, indices: LValue*, numIndicies: UInt, name: CString) -> LValue
    gepInbounds: extern(LLVMBuildInBoundsGEP) func (ptr: LValue, indices: LValue*, numIndicies: UInt, name: CString) -> LValue
    gepStruct:   extern(LLVMBuildStructGEP)   func (ptr: LValue, idx: UInt, name: CString) -> LValue

    globalString:    extern(LLVMBuildGlobalString)    func (str: CString, name: CString) -> LValue
    globalStringPtr: extern(LLVMBuildGlobalStringPtr) func (str: CString, name: CString) -> LValue

    // Cast instructions
    trunc:          extern(LLVMBuildTrunc)          func (LValue, LType, CString) -> LValue
    zext:           extern(LLVMBuildZExt)           func (LValue, LType, CString) -> LValue
    sext:           extern(LLVMBuildSExt)           func (LValue, LType, CString) -> LValue
    fptoui:         extern(LLVMBuildFPToUI)         func (LValue, LType, CString) -> LValue
    fptosi:         extern(LLVMBuildFPToSI)         func (LValue, LType, CString) -> LValue
    uitofp:         extern(LLVMBuildUIToFP)         func (LValue, LType, CString) -> LValue
    sitofp:         extern(LLVMBuildSIToFP)         func (LValue, LType, CString) -> LValue
    fptrunc:        extern(LLVMBuildFPTrunc)        func (LValue, LType, CString) -> LValue
    fpext:          extern(LLVMBuildFPExt)          func (LValue, LType, CString) -> LValue
    ptrtoint:       extern(LLVMBuildPtrToInt)       func (LValue, LType, CString) -> LValue
    inttoptr:       extern(LLVMBuildIntToPtr)       func (LValue, LType, CString) -> LValue
    bitcast:        extern(LLVMBuildBitCast)        func (LValue, LType, CString) -> LValue
    zextOrBitcast:  extern(LLVMBuildZExtOrBitCast)  func (LValue, LType, CString) -> LValue
    sextOrBitcast:  extern(LLVMBuildSExtOrBitCast)  func (LValue, LType, CString) -> LValue
    truncOrBitcast: extern(LLVMBuildTruncOrBitCast) func (LValue, LType, CString) -> LValue
    pointerCast:    extern(LLVMBuildPointerCast)    func (LValue, LType, CString) -> LValue
    intCast:        extern(LLVMBuildIntCast)        func (LValue, LType, CString) -> LValue
    fpCast:         extern(LLVMBuildFPCast)         func (LValue, LType, CString) -> LValue

    // Comparison instructions
    icmp: extern(LLVMBuildICmp) func (IntPredicate,  lhs, rhs: LValue, name: CString) -> LValue
    fcmp: extern(LLVMBuildICmp) func (RealPredicate, lhs, rhs: LValue, name: CString) -> LValue

    // Miscellaneous instructions
    phi:            extern(LLVMBuildPhi)            func (LType, name: CString) -> LValue
    call:           extern(LLVMBuildCall)           func (fn: Function, args: LValue*, numArgs: UInt, name: CString) -> LValue
    call: func ~withArray (fn: Function, args: LValue[], name := "") -> LValue {
        call(fn, args data, args length, name)
    }
    call: func ~withArrayList (fn: Function, args: ArrayList<LValue>, name := "") -> LValue {
        call(fn, args toArray() as LValue*, args size as UInt, name)
    }
    select:         extern(LLVMBuildSelect)         func (ifVal, thenVal, elseVal: LValue, name: CString) -> LValue
    vaArg:          extern(LLVMBuildVAArg)          func (list: LValue, LType, name: CString) -> LValue
    extractElement: extern(LLVMBuildExtractElement) func (vector, index: LValue, name: CString) -> LValue
    insertElement:  extern(LLVMBuildInsertElement)  func (vector, val, index: LValue, name: CString) -> LValue
    shuffleVector:  extern(LLVMBuildShuffleVector)  func (v1, v2, mask: LValue, name: CString) -> LValue
    extractValue:   extern(LLVMBuildExtractValue)   func (agg: LValue, index: UInt, name: CString) -> LValue
    insertValue:    extern(LLVMBuildInsertValue)    func (agg, val: LValue, index: UInt, name: CString) -> LValue

    isNull:    extern(LLVMBuildIsNull)    func (val: LValue, name: CString) -> LValue
    isNotNull: extern(LLVMBuildIsNotNull) func (val: LValue, name: CString) -> LValue
    ptrDiff:   extern(LLVMBuildPtrDiff)   func (lhs, rhs: LValue, name: CString) -> LValue
}


// Module providers
ModuleProvider: cover from LLVMModuleProviderRef {
    new: extern(LLVMCreateModuleProviderForExistingModule) static func (LModule) -> This

    dispose: extern(LLVMDisposeModuleProvider) func
}

// Enums
Attribute: extern(LLVMAttribute) enum {
    zext:            extern(LLVMZExtAttribute)
    sext:            extern(LLVMSExtAttribute)
    noReturn:        extern(LLVMNoReturnAttribute)
    inReg:           extern(LLVMInRegAttribute)
    structRet:       extern(LLVMStructRetAttribute)
    noUnwind:        extern(LLVMNoUnwindAttribute)
    noAlias:         extern(LLVMNoAliasAttribute)
    byVal:           extern(LLVMByValAttribute)
    nest:            extern(LLVMNestAttribute)
    readNone:        extern(LLVMReadNoneAttribute)
    readOnly:        extern(LLVMReadOnlyAttribute)
    noInline:        extern(LLVMNoInlineAttribute)
    alwaysInline:    extern(LLVMAlwaysInlineAttribute)
    optimizeForSize: extern(LLVMOptimizeForSizeAttribute)
    stackProtect:    extern(LLVMStackProtectAttribute)
    stackProtectReq: extern(LLVMStackProtectReqAttribute)
    noCapture:       extern(LLVMNoCaptureAttribute)
    noRedZone:       extern(LLVMNoRedZoneAttribute)
    noImplicitFloat: extern(LLVMNoImplicitFloatAttribute)
    naked:           extern(LLVMNakedAttribute)
}

TypeKind: extern(LLVMTypeKind) enum {
    void_:     extern(LLVMVoidTypeKind)
    float_:    extern(LLVMFloatTypeKind)
    double_:   extern(LLVMDoubleTypeKind)
    x86_fp80:  extern(LLVMX86_FP80TypeKind)
    fp128:     extern(LLVMFP128TypeKind)
    ppc_fp128: extern(LLVMPPC_FP128TypeKind)
    label:     extern(LLVMLabelTypeKind)
    integer:   extern(LLVMIntegerTypeKind)
    function:  extern(LLVMFunctionTypeKind)
    struct_:   extern(LLVMStructTypeKind)
    array:     extern(LLVMArrayTypeKind)
    pointer:   extern(LLVMPointerTypeKind)
    opaque:    extern(LLVMOpaqueTypeKind)
    vector:    extern(LLVMVectorTypeKind)
    metadata:  extern(LLVMMetadataTypeKind)
}

Linkage: extern(LLVMLinkage) enum {
    external:            extern(LLVMExternalLinkage)
    availableExternally: extern(LLVMAvailableExternallyLinkage)
    linkOnceAny:         extern(LLVMLinkOnceAnyLinkage)
    linkOnceODR:         extern(LLVMLinkOnceODRLinkage)
    weakAny:             extern(LLVMWeakAnyLinkage)
    weakODR:             extern(LLVMWeakODRLinkage)
    appending:           extern(LLVMAppendingLinkage)
    internal:            extern(LLVMInternalLinkage)
    private:             extern(LLVMPrivateLinkage)
    dllImport:           extern(LLVMDLLImportLinkage)
    dllExport:           extern(LLVMDLLExportLinkage)
    externalWeak:        extern(LLVMExternalWeakLinkage)
    ghost:               extern(LLVMGhostLinkage)
    common:              extern(LLVMCommonLinkage)
    linkerPrivate:       extern(LLVMLinkerPrivateLinkage)
}

Visibility: extern(LLVMVisibility) enum {
    default:   extern(LLVMDefaultVisibility)
    hidden:    extern(LLVMHiddenVisibility)
    protected: extern(LLVMProtectedVisibility)
}

CallConv: extern(LLVMCallConv) enum {
    ccall:       extern(LLVMCCallConv)
    fast:        extern(LLVMFastCallConv)
    cold:        extern(LLVMColdCallConv)
    x86stdcall:  extern(LLVMX86StdcallCallConv)
    x86fastcall: extern(LLVMX86FastcallCallConv)
}

IntPredicate: extern(LLVMIntPredicate) enum {
    eq:  extern(LLVMIntEQ)
    ne:  extern(LLVMIntNE)
    ugt: extern(LLVMIntUGT)
    uge: extern(LLVMIntUGE)
    ult: extern(LLVMIntULT)
    ule: extern(LLVMIntULE)
    sgt: extern(LLVMIntSGT)
    sge: extern(LLVMIntSGE)
    slt: extern(LLVMIntSLT)
    sle: extern(LLVMIntSLE)
}

RealPredicate: extern(LLVMRealPredicate) enum {
    truePred:  extern(LLVMRealPredicateTrue)
    falsePred: extern(LLVMRealPredicateFalse)
    oeq:       extern(LLVMRealOEQ)
    ogt:       extern(LLVMRealOGT)
    oge:       extern(LLVMRealOGE)
    olt:       extern(LLVMRealOLT)
    ole:       extern(LLVMRealOLE)
    one:       extern(LLVMRealONE)
    ord:       extern(LLVMRealORD)
    uno:       extern(LLVMRealUNO)
    ueq:       extern(LLVMRealUEQ)
    ugt:       extern(LLVMRealUGT)
    uge:       extern(LLVMRealUGE)
    ult:       extern(LLVMRealULT)
    ule:       extern(LLVMRealULE)
    une:       extern(LLVMRealUNE)
}
