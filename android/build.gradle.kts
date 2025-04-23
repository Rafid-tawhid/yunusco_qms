// Top-level build file where you add configuration options common to all sub-projects/modules.
buildscript {
    repositories {
        google()  // Ensure Google's Maven repo is included
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.2.2")  // Update to latest Gradle plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22")  // Kotlin plugin
        classpath("com.google.gms:google-services:4.3.15")  // Add this line for Firebase
    }
}



allprojects {
    repositories {
        google()  // Required for Firebase dependencies
        mavenCentral()
    }
}

// Your existing custom build directory logic
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}