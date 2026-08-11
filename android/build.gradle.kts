allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

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

// The SDK manager installed platform 37 as "android-37.0", a directory name
// Gradle's "android-37" hash string does not match, so any module compiling
// against 37 fails to resolve. Pinning every Android module to the newest
// platform that is actually present keeps the build local to this project —
// renaming or symlinking inside the SDK would be a change outside it.
val pinnedCompileSdk = 36

subprojects {
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.gradle.LibraryExtension> {
            compileSdk = pinnedCompileSdk
        }
    }
}
