use llvm
import llvm/[Core, ExecutionEngine, Target]
import structs/ArrayList
import math

main: func {
    LLVMLinkInJIT()
    LTarget initializeNative()
    
    myModule := LModule new("exte")

    double_ := LType double_()

    // external interface for cos
    cos := myModule addFunction("cos", double_, [double_], ["x"])

    // We've completed the definition now! Let's see the LLVM assembly
    // language representation of what we've created:
    myModule dump()

    // Now, to try to run the function!
    provider := LModuleProvider new(myModule)
    engine := LExecutionEngine new(provider)

    arg := LGenericValue newFloat(double_, PI / 4.0)
    result := engine runFunction(cos, 1, [arg] as LGenericValue*)
    result toFloat(double_) toString() println()
}
