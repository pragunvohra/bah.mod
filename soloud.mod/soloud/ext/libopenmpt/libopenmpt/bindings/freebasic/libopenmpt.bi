/'
 ' libopenmpt.bi
 ' -------------
 ' Purpose: libopenmpt public interface for FreeBASIC
 ' Notes  : (currently none)
 ' Authors: Johannes Schultz
 '          OpenMPT Devs
 ' The OpenMPT source code is released under the BSD license. Read LICENSE for more details.
 '/

#Include Once "crt/stdio.bi"
#Include Once "file.bi"

#Inclib "openmpt"

Extern "C"

/'! API version of this header file '/
Const OPENMPT_API_VERSION_MAJOR = 0
Const OPENMPT_API_VERSION_MINOR = 2
Const OPENMPT_API_VERSION = (OPENMPT_API_VERSION_MAJOR Shl 24) Or (OPENMPT_API_VERSION_MINOR Shl 16)
#Define OPENMPT_API_VERSION_STRING (OPENMPT_API_VERSION_MAJOR & "." & OPENMPT_API_VERSION_MINOR)

/'! \brief Get the libopenmpt version number
 '
 ' Returns the libopenmpt version number.
 ' \return The value represents (major Shl 24 + minor << Shr 16 + revision).
 ' \remarks Check the HiWord of the return value against OPENMPT_API_VERSION to ensure that the correct library version is loaded.
 '/
Declare Function openmpt_get_library_version() As ULong

/'! \brief Get the core version number
 '
 ' Return the OpenMPT core version number.
 ' \return The value represents (majormajor << 24 + major << 16 + minor << 8 + minorminor).
 '/
Declare Function openmpt_get_core_version() As ULong

/'! Return a verbose library version string from openmpt_get_string(). '/
#Define OPENMPT_STRING_LIBRARY_VERSION "library_version"
/'! Return a verbose library features string from openmpt_get_string(). '/
#Define OPENMPT_STRING_LIBRARY_FEATURES "library_features"
/'! Return a verbose OpenMPT core version string from openmpt_get_string(). '/
#Define OPENMPT_STRING_CORE_VERSION "core_version"
/'! Return information about the current build (e.g. the build date or compiler used) from openmpt_get_string(). '/
#Define OPENMPT_STRING_BUILD "build"
/'! Return all contributors from openmpt_get_string(). '/
#Define OPENMPT_STRING_CREDITS "credits"
/'! Return contact infromation about libopenmpt from openmpt_get_string(). '/
#Define OPENMPT_STRING_CONTACT "contact"
/'! Return the libopenmpt license from openmpt_get_string(). '/
#Define OPENMPT_STRING_LICENSE "license"

/'! \brief Free a string returned by libopenmpt
 '
 ' Frees any string that got returned by libopenmpt.
 '/
Declare Sub openmpt_free_string(ByVal Str As Const ZString Ptr)

/'! \brief Get library related metadata.
 '
 ' \param key Key to query.
 ' \return A (possibly multi-line) string containing the queried information. If no information is available, the string is empty.
 ' \sa OPENMPT_STRING_LIBRARY_VERSION
 ' \sa OPENMPT_STRING_CORE_VERSION
 ' \sa OPENMPT_STRING_BUILD
 ' \sa OPENMPT_STRING_CREDITS
 ' \sa OPENMPT_STRING_CONTACT
 ' \sa OPENMPT_STRING_LICENSE
 ' \remarks Use openmpt_get_string to automatically handle the lifetime of the returned pointer.
 '/
Declare Function openmpt_get_string_ Alias "openmpt_get_string" (ByVal key As Const ZString Ptr) As Const ZString Ptr

/'! \brief Get a list of supported file extensions
 '
 ' \return The semicolon-separated list of extensions supported by this libopenmpt build. The extensions are returned lower-case without a leading dot.
 ' \remarks Use openmpt_get_supported_extensions to automatically handle the lifetime of the returned pointer.
 '/
Declare Function openmpt_get_supported_extensions() As Const ZString Ptr

/'! \brief Query whether a file extension is supported
 '
 ' \param extension file extension to query without a leading dot. The case is ignored.
 ' \return 1 if the extension is supported by libopenmpt, 0 otherwise.
 '/
Declare Function openmpt_is_extension_supported(ByVal extension As Const ZString Ptr) As Long

Const OPENMPT_STREAM_SEEK_SET = 0
Const OPENMPT_STREAM_SEEK_CUR = 1
Const OPENMPT_STREAM_SEEK_END = 2

/'! \brief Read bytes from stream
 '
 ' Read bytes data from stream to dst.
 ' \param stream Stream to read data from
 ' \param dst Target where to copy data.
 ' \param bytes Number of bytes to read.
 ' \return Number of bytes actually read and written to dst.
 ' \retval 0 End of stream or error.
 '/
Type openmpt_stream_read_func As Function(ByVal stream As Any Ptr, ByVal dst As Any Ptr, ByVal bytes As UInteger) As UInteger

/'! \brief Seek stream position
 '
 ' Seek to stream position offset at whence.
 ' \param stream Stream to operate on.
 ' \param offset Offset to seek to.
 ' \param whence OPENMPT_STREAM_SEEK_SET, OPENMPT_STREAM_SEEK_CUR, OPENMPT_STREAM_SEEK_END. See C89 documentation.
 ' \return Returns 0 on success.
 ' \retval 0 Success.
 ' \retval -1 Failure. Position does not get updated.
 '/
Type openmpt_stream_seek_func As Function(ByVal stream As Any Ptr, ByVal offset As LongInt, ByVal whence As Long) As Long

/'! \brief Tell stream position
 '
 ' Tell position of stream.
 ' \param stream Stream to operate on.
 ' \return Current position in stream.
 ' \retval -1 Failure. Position does not get updated.
 '/
Type openmpt_stream_tell_func As Function(ByVal stream As Any Ptr) As LongInt

/'! \brief Stream callbacks
 '
 ' Stream callbacks used by libopenmpt for stream operations.
 '/
Type openmpt_stream_callbacks
	/'! \brief Read callback.
	 *
	 * \sa openmpt_stream_read_func
	 '/
	read_func As openmpt_stream_read_func

	/'! \brief Seek callback.
	 *
	 * Seek callback can be NULL if seeking is not supported.
	 * \sa openmpt_stream_seek_func
	 '/
	seek_func As openmpt_stream_seek_func

	/'! \brief Tell callback.
	 *
	 * Tell callback can be NULL if seeking is not supported.
	 * \sa openmpt_stream_tell_func
	 '/
	tell_func As openmpt_stream_tell_func
End Type

/'! \brief Logging function
 '
 ' \param message UTF-8 encoded log message.
 ' \param user User context that was passed to openmpt_module_create(), openmpt_module_create_from_memory() or openmpt_could_open_propability().
 '/
Type openmpt_log_func As Sub(ByVal message As Const ZString Ptr, ByVal user As Any Ptr)

/'! \brief Default logging function
 '
 ' Default logging function that logs anything to stderr.
 '/
Declare Sub openmpt_log_func_default(ByVal message As Const ZString Ptr, ByVal user As Any Ptr)

/'! \brief Silent logging function
 '
 ' Silent logging function that throws any log message away.
 '/
Declare Sub openmpt_log_func_silent(ByVal message As Const ZString Ptr, ByVal user As Any Ptr)

/'! \brief Roughly scan the input stream to find out whether libopenmpt might be able to open it
 '
 ' \param stream_callbacks Input stream callback operations.
 ' \param stream Input stream to scan.
 ' \param effort Effort to make when validating stream. Effort 0.0 does not even look at stream at all and effort 1.0 completely loads the file from stream. A lower effort requires less data to be loaded but only gives a rough estimate answer.
 ' \param logfunc Logging function where warning and errors are written.
 ' \param user Logging function user context.
 ' \return Propability between 0.0 and 1.0.
 ' \sa openmpt_stream_callbacks
 '/
Declare Function openmpt_could_open_propability(ByVal stream_callbacks As openmpt_stream_callbacks, ByVal stream As Any Ptr, ByVal effort As Double, ByVal logfunc As openmpt_log_func, ByVal user As Any Ptr) As Double

/'! \brief Opaque type representing a libopenmpt module
 '/
Type openmpt_module
	opaque As Any Ptr
End Type

Type openmpt_module_initial_ctl
	ctl As Const ZString Ptr
	value As Const ZString Ptr
End Type

/'! \brief Construct an openmpt_module
 '
 ' \param stream_callbacks Input stream callback operations.
 ' \param stream Input stream to load the module from.
 ' \param logfunc Log where any warnings or errors are printed to. The lifetime of the reference has to be as long as the lifetime of the module instance.
 ' \param user User-defined data associated with this module. This value will be passed to the logging callback function (logfunc)
 ' \param ctls A map of initial ctl values, see openmpt_module_get_ctls.
 ' \return A pointer to the constructed openmpt_module, or NULL on failure.
 ' \remarks The input data can be discarded after an openmpt_module has been constructed succesfully.
 ' \sa openmpt_stream_callbacks
 '/
Declare Function openmpt_module_create(ByVal stream_callbacks As openmpt_stream_callbacks, ByVal stream As Any Ptr, ByVal logfunc As openmpt_log_func = 0, ByVal user As Any Ptr = 0, ByVal ctls As Const openmpt_module_initial_ctl Ptr = 0) As openmpt_module Ptr

/'! \brief Construct an openmpt_module
 '
 ' \param filedata Data to load the module from.
 ' \param filesize Amount of data available.
 ' \param logfunc Log where any warnings or errors are printed to. The lifetime of the reference has to be as long as the lifetime of the module instance.
 ' \param user User-defined data associated with this module. This value will be passed to the logging callback function (logfunc)
 ' \param ctls A map of initial ctl values, see openmpt_module_get_ctls.
 ' \return A pointer to the constructed openmpt_module, or NULL on failure.
 ' \remarks The input data can be discarded after an openmpt_module has been constructed succesfully.
 '/
Declare Function openmpt_module_create_from_memory(ByVal filedata As Const Any Ptr, ByVal filesize As UInteger, ByVal logfunc As openmpt_log_func = 0, ByVal user As Any Ptr = 0, ByVal ctls As Const openmpt_module_initial_ctl Ptr = 0) As openmpt_module Ptr

/'! \brief Unload a previously created openmpt_module from memory.
 '
 ' \param module The module to unload.
 '/
Declare Sub openmpt_module_destroy(ByVal module As openmpt_module Ptr)

/'! \brief Master Gain
 '
 ' The related value represents a relative gain in milliBel.\n
 ' The default value is 0.\n
 ' The supported value range is unlimited.\n
 '/
Const OPENMPT_MODULE_RENDER_MASTERGAIN_MILLIBEL = 1
/'! \brief Stereo Separation
 '
 ' The related value represents the stereo separation generated by the libopenmpt mixer in percent.\n
 ' The default value is 100.\n
 ' The supported value range is [0,200].\n
 '/
Const OPENMPT_MODULE_RENDER_STEREOSEPARATION_PERCENT = 2
/'! \brief Interpolation Filter
 '
 ' The related value represents the interpolation filter length used by the libopenmpt mixer.\n
 ' The default value is 0, which indicates a recommended default value.\n
 ' The supported value range is [0,inf). Values greater than the implementation limit are clamped to the maximum supported value.\n
 ' Currently supported values:
 '  - 0: internal default
 '  - 1: no interpolation (zero order hold)
 '  - 2: linear interpolation
 '  - 4: cubic interpolation
 '  - 8: windowed sinc with 8 taps
 '/
Const OPENMPT_MODULE_RENDER_INTERPOLATIONFILTER_LENGTH = 3
/'! \brief Volume Ramping Strength
 '
 ' The related value represents the amount of volume ramping done by the libopenmpt mixer.\n
 ' The default value is -1, which indicates a recommended default value.\n
 ' The meaningful value range is [-1..10].\n
 ' A value of 0 completely disables volume ramping. This might cause clicks in sound output.\n
 ' Higher values imply slower/softer volume ramps.
 '/
Const OPENMPT_MODULE_RENDER_VOLUMERAMPING_STRENGTH = 4

/'! \brief Parameter index to use with openmpt_module_get_pattern_row_channel_command, openmpt_module_format_pattern_row_channel_command and openmpt_module_highlight_pattern_row_channel_command
 '/
Const OPENMPT_MODULE_COMMAND_NOTE = 0
Const OPENMPT_MODULE_COMMAND_INSTRUMENT = 1
Const OPENMPT_MODULE_COMMAND_VOLUMEEFFECT = 2
Const OPENMPT_MODULE_COMMAND_EFFECT = 3
Const OPENMPT_MODULE_COMMAND_VOLUME = 4
Const OPENMPT_MODULE_COMMAND_PARAMETER = 5

/'! \brief Select a subsong from a multi-song module
 '
 ' \param module The module handle to work on.
 ' \param subsong Index of the subsong. -1 plays all subsongs consecutively.
 ' \return 1 on success, 0 on failure.
 ' \sa openmpt_module_get_num_subsongs, openmpt_module_get_subsong_names
 '/
Declare Function openmpt_module_select_subsong(ByVal module As openmpt_module Ptr, ByVal subsong As Long) As Long

/'! \brief Set Repeat Count
 '
 ' \param module The module handle to work on.
 ' \param repeat_count Repeat Count
 '   - -1: repeat forever
 '   - 0: play once, repeat zero times (the default)
 '   - n>0: play once and repeat n times after that
 ' \return 1 on success, 0 on failure.
 ' \sa openmpt_module_get_repeat_count
 '/
Declare Function openmpt_module_set_repeat_count(ByVal module As openmpt_module Ptr, ByVal repeat_count As Long) As Long

/'! \brief Get Repeat Count
 '
 ' \param module The module handle to work on.
 ' \return Repeat Count
 '   - -1: repeat forever
 '   - 0: play once, repeat zero times (the default)
 '   - n>0: play once and repeat n times after that
 ' \sa openmpt_module_set_repeat_count
 '/
Declare Function openmpt_module_get_repeat_count(ByVal module As openmpt_module Ptr) As Long

/'! \brief approximate song duration
 '
 ' \param module The module handle to work on.
 ' \return Approximate duration of current subsong in seconds.
 '/
Declare Function openmpt_module_get_duration_seconds(ByVal module As openmpt_module Ptr) As Double

/'! \brief Set approximate current song position
 '
 ' \param module The module handle to work on.
 ' \param seconds Seconds to seek to. If seconds is out of range, the position gets set to song start or end respectively.
 ' \return Approximate new song position in seconds.
 ' \sa openmpt_module_get_position_seconds
 '/
Declare Function openmpt_module_set_position_seconds(ByVal module As openmpt_module Ptr, ByVal seconds As Double) As Double

/'! \brief Get current song position
 '
 ' \param module The module handle to work on.
 ' \return Current song position in seconds.
 ' \sa openmpt_module_set_position_seconds
 '/
Declare Function openmpt_module_get_position_seconds(ByVal module As openmpt_module Ptr) As Double

/'! \brief Set approximate current song position
 '
 ' If order or row are out of range, to position is not modified and the current position is returned.
 ' \param module The module handle to work on.
 ' \param order Pattern order number to seek to.
 ' \param row Pattern row number to seek to.
 ' \return Approximate new song position in seconds.
 ' \sa openmpt_module_set_position_seconds
 ' \sa openmpt_module_get_position_seconds
 '/
Declare Function openmpt_module_set_position_order_row(ByVal module As openmpt_module Ptr, ByVal order As Long, ByVal row As Long) As Double

/'! \brief Get render parameter
 '
 ' \param module The module handle to work on.
 ' \param param Parameter to query. See openmpt_module_render_param.
 ' \param value Pointer to the variable that receives the current value of the parameter.
 ' \return 1 on success, 0 on failure (invalid param or value is NULL).
 ' \sa OPENMPT_MODULE_RENDER_MASTERGAIN_MILLIBEL
 ' \sa OPENMPT_MODULE_RENDER_STEREOSEPARATION_PERCENT
 ' \sa OPENMPT_MODULE_RENDER_INTERPOLATIONFILTER_LENGTH
 ' \sa OPENMPT_MODULE_RENDER_VOLUMERAMPING_STRENGTH
 ' \sa openmpt_module_set_render_param
 '/
Declare Function openmpt_module_get_render_param(ByVal module As openmpt_module Ptr, ByVal param As Long, ByVal value As Long Ptr) As Long

/'! \brief Set render parameter
 '
 ' \param module The module handle to work on.
 ' \param param Parameter to set. See openmpt_module_render_param.
 ' \param value The value to set param to.
 ' \return 1 on success, 0 on failure (invalid param).
 ' \sa OPENMPT_MODULE_RENDER_MASTERGAIN_MILLIBEL
 ' \sa OPENMPT_MODULE_RENDER_STEREOSEPARATION_PERCENT
 ' \sa OPENMPT_MODULE_RENDER_INTERPOLATIONFILTER_LENGTH
 ' \sa OPENMPT_MODULE_RENDER_VOLUMERAMPING_STRENGTH
 ' \sa openmpt_module_get_render_param
 '/
Declare Function openmpt_module_set_render_param(ByVal module As openmpt_module Ptr, ByVal param As Long, ByVal value As Long) As Long

/'@{'/
/'! \brief Render audio data
 '
 ' \param module The module handle to work on.
 ' \param samplerate Samplerate to render output. Should be in [8000,192000], but this is not enforced.
 ' \param count Number of audio frames to render per channel.
 ' \param mono Pointer to a buffer of at least count elements that receives the mono/center output.
 ' \return The number of frames actually rendered.
 ' \retval 0 The end of song has been reached.
 ' \remarks The output buffers are only written to up to the returned number of elements.
 ' \remarks You can freely switch between any of these function if you see a need to do so. libopenmpt tries to introduce as little switching annoyances as possible. Normally, you would only use a single one of these functions for rendering a particular module.
 ' \remarks It is recommended to use the floating point API because of the greater dynamic range and no implied clipping.
 '/
Declare Function openmpt_module_read_mono(ByVal module As openmpt_module Ptr, ByVal samplerate As Long, ByVal count As UInteger, ByVal mono As Short Ptr) As UInteger

/'! \brief Render audio data
 '
 ' \param module The module handle to work on.
 ' \param samplerate Samplerate to render output. Should be in [8000,192000], but this is not enforced.
 ' \param count Number of audio frames to render per channel.
 ' \param left Pointer to a buffer of at least count elements that receives the left output.
 ' \param right Pointer to a buffer of at least count elements that receives the right output.
 ' \return The number of frames actually rendered.
 ' \retval 0 The end of song has been reached.
 ' \remarks The output buffers are only written to up to the returned number of elements.
 ' \remarks You can freely switch between any of these function if you see a need to do so. libopenmpt tries to introduce as little switching annoyances as possible. Normally, you would only use a single one of these functions for rendering a particular module.
 ' \remarks It is recommended to use the floating point API because of the greater dynamic range and no implied clipping.
 '/
Declare Function openmpt_module_read_stereo(ByVal module As openmpt_module Ptr, ByVal samplerate As Long, ByVal count As UInteger, ByVal Left As Short Ptr, ByVal Right As Short Ptr) As UInteger

/'! \brief Render audio data
 '
 ' \param module The module handle to work on.
 ' \param samplerate Samplerate to render output. Should be in [8000,192000], but this is not enforced.
 ' \param count Number of audio frames to render per channel.
 ' \param left Pointer to a buffer of at least count elements that receives the left output.
 ' \param right Pointer to a buffer of at least count elements that receives the right output.
 ' \param rear_left Pointer to a buffer of at least count elements that receives the rear left output.
 ' \param rear_right Pointer to a buffer of at least count elements that receives the rear right output.
 ' \return The number of frames actually rendered.
 ' \retval 0 The end of song has been reached.
 ' \remarks The output buffers are only written to up to the returned number of elements.
 ' \remarks You can freely switch between any of these function if you see a need to do so. libopenmpt tries to introduce as little switching annoyances as possible. Normally, you would only use a single one of these functions for rendering a particular module.
 ' \remarks It is recommended to use the floating point API because of the greater dynamic range and no implied clipping.
 '/
Declare Function openmpt_module_read_quad(ByVal module As openmpt_module Ptr, ByVal samplerate As Long, ByVal count As UInteger, ByVal Left As Short Ptr, ByVal Right As Short Ptr, ByVal rear_left As Short Ptr, ByVal rear_right As Short Ptr) As UInteger

/'! \brief Render audio data
 '
 ' \param module The module handle to work on.
 ' \param samplerate Samplerate to render output. Should be in [8000,192000], but this is not enforced.
 ' \param count Number of audio frames to render per channel.
 ' \param mono Pointer to a buffer of at least count elements that receives the mono/center output.
 ' \return The number of frames actually rendered.
 ' \retval 0 The end of song has been reached.
 ' \remarks The output buffers are only written to up to the returned number of elements.
 ' \remarks You can freely switch between any of these function if you see a need to do so. libopenmpt tries to introduce as little switching annoyances as possible. Normally, you would only use a single one of these functions for rendering a particular module.
 ' \remarks Floating point samples are in the [-1.0..1.0] nominal range. They are not clipped to that range though and thus might overshoot.
 '/
Declare Function openmpt_module_read_float_mono(ByVal module As openmpt_module Ptr, ByVal samplerate As Long, ByVal count As UInteger, ByVal mono As Single Ptr) As UInteger

/'! \brief Render audio data
 '
 ' \param module The module handle to work on.
 ' \param samplerate Samplerate to render output. Should be in [8000,192000], but this is not enforced.
 ' \param count Number of audio frames to render per channel.
 ' \param left Pointer to a buffer of at least count elements that receives the left output.
 ' \param right Pointer to a buffer of at least count elements that receives the right output.
 ' \return The number of frames actually rendered.
 ' \retval 0 The end of song has been reached.
 ' \remarks The output buffers are only written to up to the returned number of elements.
 ' \remarks You can freely switch between any of these function if you see a need to do so. libopenmpt tries to introduce as little switching annoyances as possible. Normally, you would only use a single one of these functions for rendering a particular module.
 ' \remarks Floating point samples are in the [-1.0..1.0] nominal range. They are not clipped to that range though and thus might overshoot.
 '/
Declare Function openmpt_module_read_float_stereo(ByVal module As openmpt_module Ptr, ByVal samplerate As Long, ByVal count As UInteger, ByVal Left As Single Ptr, ByVal Right As Single Ptr) As UInteger

/'! \brief Render audio data
 '
 ' \param module The module handle to work on.
 ' \param samplerate Samplerate to render output. Should be in [8000,192000], but this is not enforced.
 ' \param count Number of audio frames to render per channel.
 ' \param left Pointer to a buffer of at least count elements that receives the left output.
 ' \param right Pointer to a buffer of at least count elements that receives the right output.
 ' \param rear_left Pointer to a buffer of at least count elements that receives the rear left output.
 ' \param rear_right Pointer to a buffer of at least count elements that receives the rear right output.
 ' \return The number of frames actually rendered.
 ' \retval 0 The end of song has been reached.
 ' \remarks The output buffers are only written to up to the returned number of elements.
 ' \remarks You can freely switch between any of these function if you see a need to do so. libopenmpt tries to introduce as little switching annoyances as possible. Normally, you would only use a single one of these functions for rendering a particular module.
 ' \remarks Floating point samples are in the [-1.0..1.0] nominal range. They are not clipped to that range though and thus might overshoot.
 '/
Declare Function openmpt_module_read_float_quad(ByVal module As openmpt_module Ptr, ByVal samplerate As Long, ByVal count As UInteger, ByVal Left As Single Ptr, ByVal Right As Single Ptr, ByVal rear_left As Single Ptr, ByVal rear_right As Single Ptr) As UInteger

/'! \brief Render audio data
 '
 ' \param module The module handle to work on.
 ' \param samplerate Samplerate to render output. Should be in [8000,192000], but this is not enforced.
 ' \param count Number of audio frames to render per channel.
 ' \param interleaved_stereo Pointer to a buffer of at least count*2 elements that receives the interleaved stereo output in the order (L,R).
 ' \return The number of frames actually rendered.
 ' \retval 0 The end of song has been reached.
 ' \remarks The output buffers are only written to up to the returned number of elements.
 ' \remarks You can freely switch between any of these function if you see a need to do so. libopenmpt tries to introduce as little switching annoyances as possible. Normally, you would only use a single one of these functions for rendering a particular module.
 ' \remarks It is recommended to use the floating point API because of the greater dynamic range and no implied clipping.
 '/
Declare Function openmpt_module_read_interleaved_stereo(ByVal module As openmpt_module Ptr, ByVal samplerate As Long, ByVal count As UInteger, ByVal interleaved_stereo As Short Ptr) As UInteger

/'! \brief Render audio data
 '
 ' \param module The module handle to work on.
 ' \param samplerate Samplerate to render output. Should be in [8000,192000], but this is not enforced.
 ' \param count Number of audio frames to render per channel.
 ' \param interleaved_quad Pointer to a buffer of at least count*4 elements that receives the interleaved suad surround output in the order (L,R,RL,RR).
 ' \return The number of frames actually rendered.
 ' \retval 0 The end of song has been reached.
 ' \remarks The output buffers are only written to up to the returned number of elements.
 ' \remarks You can freely switch between any of these function if you see a need to do so. libopenmpt tries to introduce as little switching annoyances as possible. Normally, you would only use a single one of these functions for rendering a particular module.
 ' \remarks It is recommended to use the floating point API because of the greater dynamic range and no implied clipping.
 '/
Declare Function openmpt_module_read_interleaved_quad(ByVal module As openmpt_module Ptr, ByVal samplerate As Long, ByVal count As UInteger, ByVal interleaved_quad As Short Ptr) As UInteger

/'! \brief Render audio data
 '
 ' \param module The module handle to work on.
 ' \param samplerate Samplerate to render output. Should be in [8000,192000], but this is not enforced.
 ' \param count Number of audio frames to render per channel.
 ' \param interleaved_stereo Pointer to a buffer of at least count*2 elements that receives the interleaved stereo output in the order (L,R).
 ' \return The number of frames actually rendered.
 ' \retval 0 The end of song has been reached.
 ' \remarks The output buffers are only written to up to the returned number of elements.
 ' \remarks You can freely switch between any of these function if you see a need to do so. libopenmpt tries to introduce as little switching annoyances as possible. Normally, you would only use a single one of these functions for rendering a particular module.
 ' \remarks Floating point samples are in the [-1.0..1.0] nominal range. They are not clipped to that range though and thus might overshoot.
 '/
Declare Function openmpt_module_read_interleaved_float_stereo(ByVal module As openmpt_module Ptr, ByVal samplerate As Long, ByVal count As UInteger, ByVal interleaved_stereo As Single Ptr) As UInteger

/'! \brief Render audio data
 '
 ' \param module The module handle to work on.
 ' \param samplerate Samplerate to render output. Should be in [8000,192000], but this is not enforced.
 ' \param count Number of audio frames to render per channel.
 ' \param interleaved_quad Pointer to a buffer of at least count*4 elements that receives the interleaved suad surround output in the order (L,R,RL,RR).
 ' \return The number of frames actually rendered.
 ' \retval 0 The end of song has been reached.
 ' \remarks The output buffers are only written to up to the returned number of elements.
 ' \remarks You can freely switch between any of these function if you see a need to do so. libopenmpt tries to introduce as little switching annoyances as possible. Normally, you would only use a single one of these functions for rendering a particular module.
 ' \remarks Floating point samples are in the [-1.0..1.0] nominal range. They are not clipped to that range though and thus might overshoot.
 '/
Declare Function openmpt_module_read_interleaved_float_quad(ByVal module As openmpt_module Ptr, ByVal samplerate As Long, ByVal count As UInteger, ByVal interleaved_quad As Single Ptr) As UInteger
/'@}'/

/'! \brief Get the list of supported metadata item keys
 '
 ' \param module The module handle to work on.
 ' \return Metadata item keys supported by openmpt_module_get_metadata, as a semicolon-separated list.
 ' \sa openmpt_module_get_metadata
 ' \remarks Use openmpt_module_get_metadata_keys to automatically handle the lifetime of the returned pointer.
 '/
Declare Function openmpt_module_get_metadata_keys_ Alias "openmpt_module_get_metadata_keys" (ByVal module As openmpt_module Ptr) As Const ZString Ptr

/'! \brief Get a metadata item value
 '
 ' \param module The module handle to work on.
 ' \param key Metadata item key to query. Use openmpt_module_get_metadata_keys to check for available keys.
 '          Possible keys are:
 '          - type: Module format extension (e.g. it)
 '          - type_long: Tracker name associated with the module format (e.g. Impulse Tracker)
 '          - container: Container format the module file is embedded in, if any (e.g. umx)
 '          - container_long: Full container name if the module is embedded in a container (e.g. Unreal Music)
 '          - tracker: Tracker that was (most likely) used to save the module file, if known
 '          - artist: Author of the module
 '          - title: Module title
 '          - date: Date the module was last saved, in ISO-8601 format.
 '          - message: Song message. If the song message is empty or the module format does not support song messages, a list of instrument and sample names is returned instead.
 '          - message_raw: Song message. If the song message is empty or the module format does not support song messages, an empty string is returned.
 '          - warnings: A list of warnings that were generated while loading the module.
 ' \return The associated value for key.
 ' \sa openmpt_module_get_metadata_keys
 ' \remarks Use openmpt_module_get_metadata to automatically handle the lifetime of the returned pointer.
 '/
Declare Function openmpt_module_get_metadata_ Alias "openmpt_module_get_metadata" (ByVal module As openmpt_module Ptr, ByVal key As Const ZString Ptr) As Const ZString Ptr

/'! \brief Get the current speed
 '
 ' \param module The module handle to work on.
 ' \return The current speed in ticks per row.
 '/
Declare Function openmpt_module_get_current_speed(ByVal module As openmpt_module Ptr) As Long

/'! \brief Get the current tempo
 '
 ' \param module The module handle to work on.
 ' \return The current tempo in tracker units. The exact meaning of this value depends on the tempo mode being used.
 '/
Declare Function openmpt_module_get_current_tempo(ByVal module As openmpt_module Ptr) As Long

/'! \brief Get the current order
 '
 ' \param module The module handle to work on.
 ' \return The current order at which the module is being played back.
 '/
Declare Function openmpt_module_get_current_order(ByVal module As openmpt_module Ptr) As Long

/'! \brief Get the current pattern
 '
 ' \param module The module handle to work on.
 ' \return The current pattern that is being played.
 '/
Declare Function openmpt_module_get_current_pattern(ByVal module As openmpt_module Ptr) As Long

/'! \brief Get the current row
 '
 ' \param module The module handle to work on.
 ' \return The current row at which the current pattern is being played.
 '/
Declare Function openmpt_module_get_current_row(ByVal module As openmpt_module Ptr) As Long

/'! \brief Get the current amount of playing channels.
 '
 ' \param module The module handle to work on.
 ' \return The amount of sample channels that are currently being rendered.
 '/
Declare Function openmpt_module_get_current_playing_channels(ByVal module As openmpt_module Ptr) As Long

/'! \brief Get an approximate indication of the channel volume.
 '
 ' \param module The module handle to work on.
 ' \param channel The channel whose volume should be retrieved.
 ' \return The approximate channel volume.
 ' \remarks The returned value is solely based on the note velocity and does not take the actual waveform of the playing sample into account.
 '/
Declare Function openmpt_module_get_current_channel_vu_mono(ByVal module As openmpt_module Ptr, ByVal channel As Long) As Single

/'! \brief Get an approximate indication of the channel volume on the front-left speaker.
 '
 ' \param module The module handle to work on.
 ' \param channel The channel whose volume should be retrieved.
 ' \return The approximate channel volume.
 ' \remarks The returned value is solely based on the note velocity and does not take the actual waveform of the playing sample into account.
 '/
Declare Function openmpt_module_get_current_channel_vu_left(ByVal module As openmpt_module Ptr, ByVal channel As Long) As Single

/'! \brief Get an approximate indication of the channel volume on the front-right speaker.
 '
 ' \param module The module handle to work on.
 ' \param channel The channel whose volume should be retrieved.
 ' \return The approximate channel volume.
 ' \remarks The returned value is solely based on the note velocity and does not take the actual waveform of the playing sample into account.
 '/
Declare Function openmpt_module_get_current_channel_vu_right(ByVal module As openmpt_module Ptr, ByVal channel As Long) As Single

/'! \brief Get an approximate indication of the channel volume on the rear-left speaker.
 '
 ' \param module The module handle to work on.
 ' \param channel The channel whose volume should be retrieved.
 ' \return The approximate channel volume.
 ' \remarks The returned value is solely based on the note velocity and does not take the actual waveform of the playing sample into account.
 '/
Declare Function openmpt_module_get_current_channel_vu_rear_left(ByVal module As openmpt_module Ptr, ByVal channel As Long) As Single

/'! \brief Get an approximate indication of the channel volume on the rear-right speaker.
 '
 ' \param module The module handle to work on.
 ' \param channel The channel whose volume should be retrieved.
 ' \return The approximate channel volume.
 ' \remarks The returned value is solely based on the note velocity and does not take the actual waveform of the playing sample into account.
 '/
Declare Function openmpt_module_get_current_channel_vu_rear_right(ByVal module As openmpt_module Ptr, ByVal channel As Long) As Single

/'! \brief Get the number of subsongs
 '
 ' \param module The module handle to work on.
 ' \return The number of subsongs in the module. This includes any "hidden" songs (songs that share the same sequence, but start at different order indices) and "normal" subsongs or "sequences" (if the format supports them).
 ' \sa openmpt_module_get_subsong_names, openmpt_module_select_subsong
 '/
Declare Function openmpt_module_get_num_subsongs(ByVal module As openmpt_module Ptr) As Long

/'! \brief Get the number of pattern channels
 '
 ' \param module The module handle to work on.
 ' \return The number of pattern channels in the module. Not all channels do necessarily contain data.
 '/
Declare Function openmpt_module_get_num_channels(ByVal module As openmpt_module Ptr) As Long

/'! \brief Get the number of orders
 '
 ' \param module The module handle to work on.
 ' \return The number of orders in the current sequence of the module.
 '/
Declare Function openmpt_module_get_num_orders(ByVal module As openmpt_module Ptr) As Long

/'! \brief Get the number of patterns
 '
 ' \param module The module handle to work on.
 ' \return The number of distinct patterns in the module.
 '/
Declare Function openmpt_module_get_num_patterns(ByVal module As openmpt_module Ptr) As Long

/'! \brief Get the number of instruments
 '
 ' \param module The module handle to work on.
 ' \return The number of instrument slots in the module. Instruments are a layer on top of samples, and are not supported by all module formats.
 '/
Declare Function openmpt_module_get_num_instruments(ByVal module As openmpt_module Ptr) As Long

/'! \brief Get the number of samples
 '
 ' \param module The module handle to work on.
 ' \return The number of sample slots in the module.
 '/
Declare Function openmpt_module_get_num_samples(ByVal module As openmpt_module Ptr) As Long

/'! \brief Get a subsong name
 '
 ' \param module The module handle to work on.
 ' \param index The subsong whose name should be retreived
 ' \return The subsong name.
 ' \sa openmpt_module_get_num_subsongs, openmpt_module_select_subsong
 ' \remarks Use openmpt_module_get_subsong_name to automatically handle the lifetime of the returned pointer.
 '/
Declare Function openmpt_module_get_subsong_name_ Alias "openmpt_module_get_subsong_name" (ByVal module As openmpt_module Ptr, ByVal index As Long) As Const ZString Ptr

/'! \brief Get a channel name
 '
 ' \param module The module handle to work on.
 ' \param index The channel whose name should be retreived
 ' \return The channel name.
 ' \sa openmpt_module_get_num_channels
 ' \remarks Use openmpt_module_get_channel_name to automatically handle the lifetime of the returned pointer.
 '/
Declare Function openmpt_module_get_channel_name_ Alias "openmpt_module_get_channel_name" (ByVal module As openmpt_module Ptr, ByVal index As Long) As Const ZString Ptr

/'! \brief Get an order name
 '
 ' \param module The module handle to work on.
 ' \param index The order whose name should be retreived
 ' \return The order name.
 ' \sa openmpt_module_get_num_orders
 ' \remarks Use openmpt_module_get_order_name to automatically handle the lifetime of the returned pointer.
 '/
Declare Function openmpt_module_get_order_name_ Alias "openmpt_module_get_order_name" (ByVal module As openmpt_module Ptr, ByVal index As Long) As Const ZString Ptr

/'! \brief Get a pattern name
 '
 ' \param module The module handle to work on.
 ' \param index The pattern whose name should be retreived
 ' \return The pattern name.
 ' \sa openmpt_module_get_num_patterns
 ' \remarks Use openmpt_module_get_pattern_name to automatically handle the lifetime of the returned pointer.
 '/
Declare Function openmpt_module_get_pattern_name_ Alias "openmpt_module_get_pattern_name" (ByVal module As openmpt_module Ptr, ByVal index As Long) As Const ZString Ptr

/'! \brief Get an instrument name
 '
 ' \param module The module handle to work on.
 ' \param index The instrument whose name should be retreived
 ' \return The instrument name.
 ' \sa openmpt_module_get_num_instruments
 ' \remarks Use openmpt_module_get_instrument_name to automatically handle the lifetime of the returned pointer.
 '/
Declare Function openmpt_module_get_instrument_name_ Alias "openmpt_module_get_instrument_name" (ByVal module As openmpt_module Ptr, ByVal index As Long) As Const ZString Ptr

/'! \brief Get a sample name
 '
 ' \param module The module handle to work on.
 ' \param index The sample whose name should be retreived
 ' \return The sample name.
 ' \sa openmpt_module_get_num_samples
 ' \remarks Use openmpt_module_get_sample_name to automatically handle the lifetime of the returned pointer.
 '/
Declare Function openmpt_module_get_sample_name_ Alias "openmpt_module_get_sample_name" (ByVal module As openmpt_module Ptr, ByVal index As Long) As Const ZString Ptr

/'! \brief Get pattern at order position
 '
 ' \param module The module handle to work on.
 ' \param order The order item whose pattern index should be retrieved.
 ' \return The pattern index found at the given order position of the current sequence.
 '/
Declare Function openmpt_module_get_order_pattern(ByVal module As openmpt_module Ptr, ByVal order As Long) As Long

/'! \brief Get the number of rows in a pattern
 '
 ' \param module The module handle to work on.
 ' \param pattern The pattern whose row count should be retrieved.
 ' \return The number of rows in the given pattern. If the pattern does not exist, 0 is returned.
 '/
Declare Function openmpt_module_get_pattern_num_rows(ByVal module As openmpt_module Ptr, ByVal pattern As Long) As Long

/'! \brief Get raw pattern content
 '
 ' \param module The module handle to work on.
 ' \param pattern The pattern whose data should be retrieved.
 ' \param row The row from which the data should be retrieved.
 ' \param channel The channel from which the data should be retrieved.
 ' \param command The cell index at which the data should be retrieved. See openmpt_module_command_index
 ' \return The internal, raw pattern data at the given pattern position.
 '/
Declare Function openmpt_module_get_pattern_row_channel_command_(ByVal module As openmpt_module Ptr, ByVal pattern As Long, ByVal row As Long, ByVal channel As Long, ByVal command_ As Long) As UByte

/'! \brief Get formatted (human-readable) pattern content
 '
 ' \param module The module handle to work on.
 ' \param pattern The pattern whose data should be retrieved.
 ' \param row The row from which the data should be retrieved.
 ' \param channel The channel from which the data should be retrieved.
 ' \param command The cell index at which the data should be retrieved.
 ' \return The formatted pattern data at the given pattern position. See openmpt_module_command_index
 ' \sa openmpt_module_highlight_pattern_row_channel_command
 ' \remarks Use openmpt_module_format_pattern_row_channel_command to automatically handle the lifetime of the returned pointer.
 '/
Declare Function openmpt_module_format_pattern_row_channel_command_ Alias "openmpt_module_format_pattern_row_channel_command" (ByVal module As openmpt_module Ptr, ByVal pattern As Long, ByVal row As Long, ByVal channel As Long, ByVal command_ As Long) As Const ZString Ptr

/'! \brief Get highlighting information for formatted pattern content
 '
 ' \param module The module handle to work on.
 ' \param pattern The pattern whose data should be retrieved.
 ' \param row The row from which the data should be retrieved.
 ' \param channel The channel from which the data should be retrieved.
 ' \param command The cell index at which the data should be retrieved. See openmpt_module_command_index
 ' \return The highlighting string for the formatted pattern data as retrived by openmpt_module_get_pattern_row_channel_command at the given pattern position.
 ' \remarks The returned string will map each character position of the string returned by openmpt_module_get_pattern_row_channel_command to a highlighting instruction.
 '          Possible highlighting characters are:
 '          - " " : empty/space
 '          - "." : empty/dot
 '          - "n" : generic note
 '          - "m" : special note
 '          - "i" : generic instrument
 '          - "u" : generic volume column effect
 '          - "v" : generic volume column parameter
 '          - "e" : generic effect column effect
 '          - "f" : generic effect column parameter
 ' \sa openmpt_module_get_pattern_row_channel_command
 ' \remarks Use openmpt_module_highlight_pattern_row_channel_command to automatically handle the lifetime of the returned pointer.
 '/
Declare Function openmpt_module_highlight_pattern_row_channel_command_ Alias "openmpt_module_highlight_pattern_row_channel_command" (ByVal module As openmpt_module Ptr, ByVal pattern As Long, ByVal row As Long, ByVal channel As Long, ByVal command_ As Long) As Const ZString Ptr

/'! \brief Get formatted (human-readable) pattern content
 '
 ' \param module The module handle to work on.
 ' \param pattern The pattern whose data should be retrieved.
 ' \param row The row from which the data should be retrieved.
 ' \param channel The channel from which the data should be retrieved.
 ' \param width The maximum number of characters the string should contain. 0 means no limit.
 ' \param pad If true, the string will be resized to the exact length provided in the width parameter.
 ' \return The formatted pattern data at the given pattern position.
 ' \sa openmpt_module_highlight_pattern_row_channel
 ' \remarks Use openmpt_module_format_pattern_row_channel to automatically handle the lifetime of the returned pointer.
 '/
Declare Function openmpt_module_format_pattern_row_channel_ Alias "openmpt_module_format_pattern_row_channel" (ByVal module As openmpt_module Ptr, ByVal pattern As Long, ByVal row As Long, ByVal channel As Long, ByVal width_ As UInteger, ByVal pad As Long) As Const ZString Ptr

/'! \brief Get highlighting information for formatted pattern content
 '
 ' \param module The module handle to work on.
 ' \param pattern The pattern whose data should be retrieved.
 ' \param row The row from which the data should be retrieved.
 ' \param channel The channel from which the data should be retrieved.
 ' \param width The maximum number of characters the string should contain. 0 means no limit.
 ' \param pad If true, the string will be resized to the exact length provided in the width parameter.
 ' \return The highlighting string for the formatted pattern data as retrived by openmpt_module_format_pattern_row_channel at the given pattern position.
 ' \sa openmpt_module_format_pattern_row_channel
 ' \remarks Use openmpt_module_highlight_pattern_row_channel to automatically handle the lifetime of the returned pointer.
 '/
Declare Function openmpt_module_highlight_pattern_row_channel_ Alias "openmpt_module_highlight_pattern_row_channel" (ByVal module As openmpt_module Ptr, ByVal pattern As Long, ByVal row As Long, ByVal channel As Long, ByVal width_ As UInteger, ByVal pad As Long) As Const ZString Ptr

/'! \brief Retrieve supported ctl keys
 '
 ' \param module The module handle to work on.
 ' \return A semicolon-separated list containing all supported ctl keys.
 ' \remarks Currently supported ctl values are:
 '          - load.skip_samples: Set to "1" to avoid loading samples into memory
 '          - load.skip_patterns: Set to "1" to avoid loading patterns into memory
 '          - load.skip_subsongs_init: Set to "1" to avoid pre-initializing subsongs. Skipping results in faster module loading but slower seeking.
 '          - seek.sync_samples: Set to "1" to sync sample playback when using openmpt_module_set_position_seconds or openmpt_module_set_position_order_row.
 '          - play.tempo_factor: Set a floating point tempo factor. "1.0" is the default tempo.
 '          - play.pitch_factor: Set a floating point pitch factor. "1.0" is the default pitch.
 '          - dither: Set the dither algorithm that is used for the 16 bit versions of openmpt_module_read. Supported values are:
 '                    - 0: No dithering.
 '                    - 1: Default mode. Chosen by OpenMPT code, might change.
 '                    - 2: Rectangular, 0.5 bit depth, no noise shaping (original ModPlug Tracker).
 '                    - 3: Rectangular, 1 bit depth, simple 1st order noise shaping
 ' \remarks Use openmpt_module_get_ctls to automatically handle the lifetime of the returned pointer.
 '/
Declare Function openmpt_module_get_ctls_ Alias "openmpt_module_get_ctls" (ByVal module As openmpt_module Ptr) As Const ZString Ptr

/'! \brief Get current ctl value
 '
 ' \param module The module handle to work on.
 ' \param ctl The ctl key whose value should be retrieved.
 ' \return The associated ctl value, or NULL on failure.
 ' \sa openmpt_module_get_ctls
 ' \remarks Use openmpt_module_ctl_get to automatically handle the lifetime of the returned pointer.
 '/
Declare Function openmpt_module_ctl_get_ Alias "openmpt_module_ctl_get" (ByVal module As openmpt_module Ptr, ByVal ctl As Const ZString Ptr) As Const ZString Ptr

/'! \brief Set ctl value
 '
 ' \param module The module handle to work on.
 ' \param ctl The ctl key whose value should be set.
 ' \param value The value that should be set.
 ' \sa openmpt_module_get_ctls
 '/
Declare Function openmpt_module_ctl_set(ByVal module As openmpt_module Ptr, ByVal ctl As Const ZString Ptr, ByVal value As Const ZString Ptr) As Long

/'! Callbacks for CRT FILE* handling '/
Function openmpt_stream_read_func(ByVal stream As Any Ptr, ByVal dst As Any Ptr, ByVal bytes As UInteger) As UInteger
	Dim retval As UInteger = 0
	Var f = Cast( FILE Ptr, stream )
	If ( f = 0 ) Then Return 0
	retval = fread( dst, 1, bytes, f )
	If ( retval <= 0 ) Then Return 0
	Return retval
End Function

/'! Callbacks for CRT FILE* handling '/
Function openmpt_stream_seek_func(ByVal stream As Any Ptr, ByVal offset As LongInt, ByVal whence As Long) As Long
	Var f = Cast( FILE Ptr, stream )
	If ( f = 0 ) Then Return -1
	Dim fwhence As Long
	Select Case whence
	Case OPENMPT_STREAM_SEEK_SET
		fwhence = SEEK_SET
	Case OPENMPT_STREAM_SEEK_CUR
		fwhence = SEEK_CUR
	Case OPENMPT_STREAM_SEEK_END
		fwhence = SEEK_END
	Case Else
		Return -1
	End Select
	Return IIf(fseek( f, offset, fwhence ) <> 0, -1, 0)
End Function

/'! Callbacks for CRT FILE* handling '/
Function openmpt_stream_tell_func(ByVal stream As Any Ptr) As LongInt
	Dim retval As LongInt = 0
	Var f = Cast( FILE Ptr, stream )
	If ( f = 0 ) Then
		Return -1
	EndIf
	retval = ftell( f )
	If ( retval < 0 ) Then Return -1
	Return retval
End Function

End Extern

/'! Retrieve the set of stream callbacks for CRT FILE* '/
Function openmpt_stream_get_file_callbacks() As openmpt_stream_callbacks
	Static callbacks As openmpt_stream_callbacks = (@openmpt_stream_read_func, @openmpt_stream_seek_func, @openmpt_stream_tell_func)
	Return callbacks
End Function

/'! \brief Construct an openmpt_module
 '
 ' \param file The FreeBASIC file handle to load from.
 ' \param logfunc Log where any warnings or errors are printed to. The lifetime of the reference has to be as long as the lifetime of the module instance.
 ' \param user User-defined data associated with this module. This value will be passed to the logging callback function (logfunc)
 ' \param ctls A map of initial ctl values, see openmpt_module_get_ctls.
 ' \return A pointer to the constructed openmpt_module, or NULL on failure.
 ' \remarks The file handle can be closed after an openmpt_module has been constructed succesfully.
 '/
Function openmpt_module_create_from_fbhandle(_
		ByVal file As Integer,_
		ByVal logfunc As openmpt_log_func = 0,_
		ByVal user As Any Ptr = 0,_
		ByVal ctls As Const openmpt_module_initial_ctl Ptr = 0) As openmpt_module Ptr
	Return openmpt_module_create(openmpt_stream_get_file_callbacks(), Cast(FILE Ptr, FileAttr(file, fbFileAttrHandle)), logfunc, user, ctls)
End Function

/'! \brief Construct an openmpt_module
 '
 ' \param filename The file to load from.
 ' \param logfunc Log where any warnings or errors are printed to. The lifetime of the reference has to be as long as the lifetime of the module instance.
 ' \param user User-defined data associated with this module. This value will be passed to the logging callback function (logfunc)
 ' \param ctls A map of initial ctl values, see openmpt_module_get_ctls.
 ' \return A pointer to the constructed openmpt_module, or NULL on failure.
 '/
Function openmpt_module_create_from_filename(_
		ByRef filename As String,_
		ByVal logfunc As openmpt_log_func = 0,_
		ByVal user As Any Ptr = 0,_
		ByVal ctls As Const openmpt_module_initial_ctl Ptr = 0) As openmpt_module Ptr
	Var file = fopen(filename, "rb")
	Var retval = CPtr(openmpt_module Ptr, 0)
	If(file <> 0) Then
		retval = openmpt_module_create(openmpt_stream_get_file_callbacks(), file, logfunc, user, ctls)
		fclose(file)
	EndIf
	Return retval
End Function

' String handling for wrapping and freeing ZStrings returned by libopenmpt
Function openmpt_get_zstring(sz As Const ZString Ptr) As String
	If(sz = 0) Then Return ""
	Dim As String s = *sz
	openmpt_free_string(sz)
	Return s
End Function

Function openmpt_get_string(ByVal key As Const ZString Ptr) As String
	Return openmpt_get_zstring(openmpt_get_string_(key))
End Function

Function openmpt_module_get_metadata_keys(ByVal module As openmpt_module Ptr) As String
	Return openmpt_get_zstring(openmpt_module_get_metadata_keys_(module))
End Function

Function openmpt_module_get_metadata(ByVal module As openmpt_module Ptr, ByVal key As Const ZString Ptr) As String
	Return openmpt_get_zstring(openmpt_module_get_metadata_(module, key))
End Function

Function openmpt_module_get_subsong_name(ByVal module As openmpt_module Ptr, ByVal index As Long) As String
	Return openmpt_get_zstring(openmpt_module_get_subsong_name_(module, index))
End Function

Function openmpt_module_get_channel_name(ByVal module As openmpt_module Ptr, ByVal index As Long) As String
	Return openmpt_get_zstring(openmpt_module_get_channel_name_(module, index))
End Function

Function openmpt_module_get_order_name(ByVal module As openmpt_module Ptr, ByVal index As Long) As String
	Return openmpt_get_zstring(openmpt_module_get_order_name_(module, index))
End Function

Function openmpt_module_get_pattern_name(ByVal module As openmpt_module Ptr, ByVal index As Long) As String
	Return openmpt_get_zstring(openmpt_module_get_pattern_name_(module, index))
End Function

Function openmpt_module_get_instrument_name(ByVal module As openmpt_module Ptr, ByVal index As Long) As String
	Return openmpt_get_zstring(openmpt_module_get_instrument_name_(module, index))
End Function

Function openmpt_module_get_sample_name(ByVal module As openmpt_module Ptr, ByVal index As Long) As String
	Return openmpt_get_zstring(openmpt_module_get_sample_name_(module, index))
End Function

Function openmpt_module_format_pattern_row_channel_command(ByVal module As openmpt_module Ptr, ByVal pattern As Long, ByVal row As Long, ByVal channel As Long, ByVal command_ As Long) As String
	Return openmpt_get_zstring(openmpt_module_format_pattern_row_channel_command_(module, pattern, row, channel, command_))
End Function

Function openmpt_module_highlight_pattern_row_channel_command(ByVal module As openmpt_module Ptr, ByVal pattern As Long, ByVal row As Long, ByVal channel As Long, ByVal command_ As Long) As String
	Return openmpt_get_zstring(openmpt_module_highlight_pattern_row_channel_command_(module, pattern, row, channel, command_))
End Function

Function openmpt_module_format_pattern_row_channel(ByVal module As openmpt_module Ptr, ByVal pattern As Long, ByVal row As Long, ByVal channel As Long, ByVal width_ As UInteger, ByVal pad As Long) As String
	Return openmpt_get_zstring(openmpt_module_format_pattern_row_channel_(module, pattern, row, channel, width_, pad))
End Function

Function openmpt_module_highlight_pattern_row_channel(ByVal module As openmpt_module Ptr, ByVal pattern As Long, ByVal row As Long, ByVal channel As Long, ByVal width_ As UInteger, ByVal pad As Long) As String
	Return openmpt_get_zstring(openmpt_module_highlight_pattern_row_channel_(module, pattern, row, channel, width_, pad))
End Function

Function openmpt_module_get_ctls(ByVal module As openmpt_module Ptr) As String
	Return openmpt_get_zstring(openmpt_module_get_ctls_(module))
End Function

Function openmpt_module_ctl_get(ByVal module As openmpt_module Ptr, ByVal ctl As Const ZString Ptr) As String
	Return openmpt_get_zstring(openmpt_module_ctl_get_(module, ctl))
End Function
