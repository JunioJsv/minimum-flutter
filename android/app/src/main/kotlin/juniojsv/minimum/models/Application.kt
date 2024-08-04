package juniojsv.minimum.models

data class Application(val label: String, val packageName: String, val versionName: String) {
    fun serialize(): Map<String, Any> {
        return mapOf(
            "label" to label,
            "package" to packageName,
            "version" to versionName,
        )
    }
}
