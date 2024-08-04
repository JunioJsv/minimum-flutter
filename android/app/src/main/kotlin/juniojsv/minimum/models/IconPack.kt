package juniojsv.minimum.models

data class IconPack(val label: String, val packageName: String) {
    fun serialize(): Map<String, Any> {
        return mapOf(
            "label" to label,
            "package" to packageName
        )
    }
}
