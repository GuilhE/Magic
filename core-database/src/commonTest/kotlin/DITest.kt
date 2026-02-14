import kotlin.experimental.ExperimentalObjCRefinement
import kotlin.native.HiddenFromObjC
import org.koin.core.module.Module

@OptIn(ExperimentalObjCRefinement::class)
@HiddenFromObjC
expect fun databaseDiTestModule(): Module