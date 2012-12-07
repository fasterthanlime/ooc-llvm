use llvm
import llvm/Core

Target: cover from LLVMTargetDataRef {
    initializeAllInfos: extern(LLVMInitializeAllTargetInfos) static func

    initializeAll: extern(LLVMInitializeAllTargets) static func

    initializeNative: extern(LLVMInitializeNativeTarget) static func

    new: extern(LLVMCreateTargetData) static func (String) -> This

//    addToPassManager: extern(LLVMAddTargetData) static func (PassManager)

    toString: extern(LLVMCopyStringRepOfTargetData) func -> String

    byteOrder: extern(LLVMByteOrder) func -> ByteOrdering

    pointerSize: extern(LLVMPointerSize) func -> UInt

    intPointerType: extern(LLVMIntPtrType) func -> LType

    sizeOfTypeInBits: extern(LLVMSizeOfTypeInBits) func (LType) -> ULLong

    storeSizeOfType: extern(LLVMStoreSizeOfType) func (LType) -> ULLong

    abiSizeOfType: extern(LLVMABISizeOfType) func (LType) -> ULLong

    abiAlignmentOfType: extern(LLVMABIAlignmentOfType) func (LType) -> UInt

    callFrameAlignmentOfType: extern(LLVMCallFrameAlignmentOfType) func (LType) -> UInt

    preferredAlignmentOfType: extern(LLVMPreferredAlignmentOfType) func (LType) -> UInt

    preferredAlignmentOfGlobal: extern(LLVMPreferredAlignmentOfGlobal) func (Value) -> UInt

    elementAtOffset: extern(LLVMElementAtOffset) func (LType, ULLong) -> UInt

    offsetOfElement: extern(LLVMOffsetOfElement) func (LType, UInt) -> ULLong

    invalidateStructLayout: extern(LLVMInvalidateStructLayout) func (LType)

    dispose: extern(LLVMDisposeTargetData) func
}

ByteOrdering: enum { /* extern(enum LLVMByteOrdering) */
    bigEndian: extern(LLVMBigEndian)
    littleEndian: extern(LLVMLittleEndian)
}
