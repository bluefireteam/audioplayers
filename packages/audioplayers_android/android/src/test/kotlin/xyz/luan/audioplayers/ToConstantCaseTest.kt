package xyz.luan.audioplayers

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

internal class ToConstantCaseTest {
    @Test
    fun `convert from sentence case`() {
        assertThat("foo".toConstantCase()).isEqualTo("FOO")
        assertThat("foo bar".toConstantCase()).isEqualTo("FOO_BAR")
    }

    @Test
    fun `convert from camelCase`() {
        assertThat("foo".toConstantCase()).isEqualTo("FOO")
        assertThat("fooBar".toConstantCase()).isEqualTo("FOO_BAR")
    }
}
