use llvm
import Core

// Generic values
LGenericValue: cover from LLVMGenericValueRef {
    newPointer: extern(LLVMCreateGenericValueOfPointer) static func ~pointer (Pointer) -> This
    newFloat: extern(LLVMCreateGenericValueOfFloat) static func ~float (LType, Double) -> This

    newInt: extern(LLVMCreateGenericValueOfInt) static func (LType, ULLong, Int) -> This

    intWidth: extern(LLVMGenericValueIntWidth) func -> UInt
    toInt: extern(LLVMGenericValueToInt) func (isSigned: Int) -> ULLong
    toPointer: extern(LLVMGenericValueToPointer) func -> Pointer
    toFloat: func (ty: LType) -> Double {
        LLVMGenericValueToFloat(ty, this)
    }
}

LLVMGenericValueToFloat: extern func (LType, LGenericValue) -> Double

// Execution engines
ExecutionEngine: cover from LLVMExecutionEngineRef {
    new: static func (mp: ModuleProvider) -> This {
        e: This = null
        error := null as String
        LLVMCreateJITCompiler(e&, mp, 0, error&)
        if(error != null) {
            Exception new(error) throw()
        }
        return e
    }

    dispose: extern(LLVMDisposeExecutionEngine) func

    runFunction: extern(LLVMRunFunction) func (fn: LValue, numArgs: UInt, args: LGenericValue*) -> LGenericValue

    recompileAndRelinkFunction: extern(LLVMRecompileAndRelinkFunction) func (fn: LValue) -> Pointer
}

LLVMCreateJITCompiler: extern func (ExecutionEngine*, ModuleProvider, UInt, String*) -> Int
