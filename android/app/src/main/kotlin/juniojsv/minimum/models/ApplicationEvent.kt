package juniojsv.minimum.models


enum class ApplicationEventType {
    ON_PACKAGE_REMOVED,
    ON_PACKAGE_ADDED,
    ON_PACKAGE_CHANGED,
    ON_PACKAGES_AVAILABLE,
    ON_PACKAGES_UNAVAILABLE
}

data class ApplicationEvent(
    val type: ApplicationEventType,
    val packagesNames: List<String>,
) {
    fun serialize(): Map<String, Any> {
        return mapOf(
            "type" to type.toString(),
            "packages" to packagesNames,
        )
    }
}
