package juniojsv.minimum.utils

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.os.Build
import java.io.ByteArrayOutputStream

private val compressFormat =
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R)
        Bitmap.CompressFormat.WEBP_LOSSY
    else Bitmap.CompressFormat.PNG

fun Drawable.toByteArray(width: Int? = null, height: Int? = null): ByteArray {
    val bitmap = Bitmap.createBitmap(
        width ?: intrinsicWidth,
        height ?: intrinsicHeight,
        Bitmap.Config.ARGB_8888
    )
    val canvas = Canvas(bitmap)
    setBounds(0, 0, canvas.width, canvas.height)
    draw(canvas)

    return ByteArrayOutputStream().use {
        bitmap.compress(compressFormat, 75, it)
        bitmap.recycle()
        it.toByteArray()
    }
}