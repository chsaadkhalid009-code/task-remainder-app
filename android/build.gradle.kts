allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://storage.googleapis.com/download.flutter.io")
        }
    }
}

rootProject.layout.buildDirectory.set(file("${project.projectDir}/../../build"))

subprojects {
    project.layout.buildDirectory.set(file("${project.projectDir}/../../build/${project.name}"))
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
