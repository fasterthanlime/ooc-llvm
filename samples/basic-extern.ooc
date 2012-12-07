use llvm
import llvm/[Core, ExecutionEngine, Target]
import structs/ArrayList
import math

main: func {
    LLVMLinkInJIT()
    Target initializeNative()
    
    myModule := LModule new("exte")

    double_ := Type double_()

    // external interface for cos
    cos := myModule addFunction("cos", double_, [double_], ["x"])

    // We've completed the definition now! Let's see the LLVM assembly
    // language representation of what we've created:
    myModule dump()

    // Now, to try to run the function!
    provider := ModuleProvider new(myModule)
    engine := ExecutionEngine new(provider)

    arg := GenericValue newFloat(double_, PI / 4.0)
    result := engine runFunction(cos, 1, [arg] as GenericValue*)
    result toFloat(double_) toString() println()
}
