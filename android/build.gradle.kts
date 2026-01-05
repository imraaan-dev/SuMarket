import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

plugins {
    // Android plugin is applied in the module, so keep apply false here
    id("com.android.application") version "8.9.1" apply false

    // Google Services plugin (needed for google-services.json)
    id("com.google.gms.google-services") version "4.4.4" apply false

    // If you use Kotlin in Android (very likely), keep this too
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

// (Optional but OK) Repos here if you aren't using settings.gradle.kts dependencyResolutionManagement
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ---- Your custom build directory relocation (kept, but organized) ----
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
