#ifndef _CONFIGURATIONDEFS_H_
#define _CONFIGURATIONDEFS_H_

#define PM_Notification_Value "VALUE"

// Player global setting
#define PM_PLAYER_CONFIG_LOGFILE "PM_Player_Config_LogFile"
#define RTD1185MEDIAPLAYER "RTD1185MediaPlayer"

// Lan setting
#define LIVEDOMAIN_LAN "LiveDomain_Lan"

#define PM_LANDOMAIN_CONFIG_RECEIPTIONPORT "PM_LanDomain_Config_Receiption_Port"
#define PM_LANDOMAIN_CONFIG_VIDEOPORT "PM_LanDomain_Config_Video_Port"
#define PM_LANDOMAIN_CONFIG_AUDIOPORT "PM_LanDomain_Config_Audio_Port"
#define PM_LANDOMAIN_CONFIG_ADVPROTOCOL "PM_LanDomain_Config_AdvProtocol"
#define PM_LANDOMAIN_CONFIG_EnablePacketTransporter "PM_LanDomain_Config_EnablePacketTransporter"
#define PM_LANDOMAIN_CONFIG_ChannelsTakenByTransporter "PM_LanDomain_Config_ChannelsTakenByTransporter"

#define PM_LANDOMAIN_GROUP_UNICAST "PM_LanDomain_Group_Unicast"

// Jingle setting

// Kworld p2p setting
#define PM_kP2PSession_CONFIG_IndexServerIP "PM_kP2PSession_CONFIG_IndexServerIP"
#define PM_kP2PSession_CONFIG_IndexServerPort "PM_kP2PSession_CONFIG_IndexServerPort"
#define PM_kP2PSession_CONFIG_MediaServerID "PM_kP2PSession_CONFIG_MediaServerID"
#define PM_kP2PSession_CONFIG_DeviceID "PM_kP2PSession_CONFIG_DeviceID"
#define PM_kP2PSession_CONFIG_ServicePort "PM_kP2PSession_CONFIG_ServicePort"
#define PM_kP2PSession_CONFIG_ReadRootPath "PM_kP2PSession_CONFIG_ReadRootPath"
#define PM_kP2PSession_CONFIG_WriteRootPath "PM_kP2PSession_CONFIG_WriteRootPath"



// 
//
// ******** Playback controller related **********
//
//

// Video Record controller
#define PM_PLAYBACKCONTROL_VIDEORECORDER "PBC_VideoRecorder"
#define PM_PLAYBACKCONTROL_MULTIMODE "PBC_MultiMode"

#define VS_TRANSMITTER_VR_ADAPTER "VS_Transmitter_VR_Adapter"
#define VS_TRANSMITTER_VR_ADAPTER_OUTPUT_FILENAME "VS_Transmitter_VR_Adapter_Output_FileName"
#define VS_TRANSMITTER_VR_ADAPTER_BROADCAST "VS_Transmitter_VR_Adapter_Broadcast"
#define VS_TRANSMITTER_VR_ADAPTER_BROADCAST_BACKUP "VS_Transmitter_VR_Adapter_Broadcast_Backup"

// Conference Service
#define CS_VS_TRANSMITTER_VR_ADAPTER "CS_VS_Transmitter_VR_Adapter"
#define PM_PLAYBACKCONTROL_CONFERENCESERVICE "PBC_ConferenceService"
// Feature - Conference Info
#define PM_FEATURE_CONFERENCEINFO "PM_Feature_ConferenceInfo"

// Session PBC
#define PhM_Session_PBC "PhM_Session_PBC"
#define PM_FEATURE_PhotoSession "PM_Feature_PhotoSession"

// Video playback controller
#define PM_PLAYBACKCONTROL_VideoPlayer "PBC_VideoPlayer"
#define PM_PLAYBACKCONTROL_VideoPlayer_Input_FileName "PM_PLAYBACKCONTROL_VideoPlayer_Input_FileName"

// Session PBC
#define PM_PLAYBACKCONTROL_FileShare "PBC_FileShare"


//
//
// ******** End - Playback controller **********
//
//

// Feature - Desktop
#define PM_FEATURE_DESKTOP "PM_Feature_Desktop"
#define PM_FEATURE_PUSHDESKTOP "PM_Feature_PushDesktop"
#define PM_DESKTOP_CONFIG_ENABLE "PM_Desktop_Enable"
#define PM_DESKTOP_CONFIG_USERNAME "PM_Desktop_UserName"
#define PM_DESKTOP_CONFIG_PASSWORD "PM_Desktop_Password"
#define PM_DESKTOP_CONFIG_EXTENDED "PM_Desktop_Extended"
#define PM_DESKTOP_CONFIG_MIRRORMAIN "PM_Desktop_MirrorMain"
#define PM_DESKTOP_CONFIG_MIRRORAREA "PM_Desktop_MirrorArea"
#define PM_DESKTOP_CONFIG_MIRRORAREA_TOP "PM_Desktop_MirrorArea_Top"
#define PM_DESKTOP_CONFIG_MIRRORAREA_LEFT "PM_Desktop_MirrorArea_Left"
#define PM_DESKTOP_CONFIG_MIRRORAREA_WIDTH "PM_Desktop_MirrorArea_Width"
#define PM_DESKTOP_CONFIG_MIRRORAREA_HEIGHT "PM_Desktop_MirrorArea_Height"
#define PM_DESKTOP_CONFIG_MIRRORAREA_CHANGE "PM_Desktop_MirrorArea_Change"
#define PM_DESKTOP_CONFIG_RTD1185_RES "PM_Desktop_RTD1185_Res"
#define PM_DESKTOP_CONFIG_AUTO_ADJUST "PM_Desktop_Auto_Adjust"
#define PM_DESKTOP_CONFIG_RECONSTRUCT "PM_Desktop_Reconstruct"
#define PM_DESKTOP_CONFIG_AUDIO_SOURCE "PM_Desktop_Config_Audio_Source" // used for xp
#define PM_DESKTOP_CONFIG_OVERLAY_BLENDING "PM_Desktop_Config_Overlay_Blending" // used for xp to solve cursor flicking
#define PM_DESKTOP_CONFIG_CURSOR_BLENDING "PM_Desktop_Config_Cursor_Blending"

#define PM_Display_DefaultDisplayView "PM_Display_DefaultDisplayView"
#define PM_Display_Mode "PM_Display_Mode"
#define PM_Display_DisplayViewID "PM_Display_DisplayViewID"
#define PM_Display_DisplayView "PM_Display_DisplayView"


#define PM_DESKTOP_CONFIG_TESTERNAME "PM_Desktop_TesterName"
#define PM_DESKTOP_CONFIG_TESTERPASSWORD "PM_Desktop_TesterPassword"

#define PM_DESKTOP_CONFIG_BlankDesktop "PM_DESKTOP_CONFIG_BlankDesktop"


// Feature - Cam
#define PM_FEATURE_CAM "PM_Feature_Cam"
#define PM_FEATURE_PUSHCAM "PM_Feature_PushCam"
#define PM_CAM_CONFIG_ENABLE "PM_Cam_Enable"
#define PM_CAM_CONFIG_VIDEO_SOURCE "PM_Cam_Config_Video_Source"
#define PM_CAM_CONFIG_AUDIO_SOURCE "PM_Cam_Config_Audio_Source"

// Feature - ImageCast
#define PM_FEATURE_IMAGECAST "PM_Feature_ImageCast"
// CMD - CastImage(int Type, string FilePathName)
#define PM_CMD_CASTIMAGE "PM_CMD_CastImage"
#define PM_CMD_CASTIMAGE_ARG_Type "PM_CMD_CastImage_Arg_Type"
#define PM_CMD_CASTIMAGE_ARG_FILEPATHNAME "PM_CMD_CastImage_Arg_FilePathName"
#define PM_EVENT_CASTIMAGE "PM_Event_CastImage"

// Feature - OnlyRX
#define PM_FEATURE_ONLYRX "PM_Feature_OnlyRX"
#define PM_ONLYRX_CONFIG_ENABLE "PM_OnlyRX_Enable"
#define PM_ONLYRX_CONFIG_VIDEO_SOURCE "PM_OnlyRX_Config_Video_Source"
#define PM_ONLYRX_CONFIG_AUDIO_SOURCE "PM_OnlyRX_Config_Audio_Source"

// Feature - FileTransporter
#define PM_FEATURE_FileTransporter "PM_FEATURE_FileTransporter"
#define PM_FT_CONFIG_ENABLE "PM_FT_Enable"
#define PM_FT_RootPaths "PM_FT_RootPaths"
#define PM_FT_DefaultRootPath "root"
// Apple translator
#define PM_FEATURE_FileTransporterApple "PM_FEATURE_FileTransporterApple"


//
// Video pipeline configuration
//
#define VSCONFIG_DEFAULT  "Default"
#define VSCONFIG_NONE   ""

#define PM_VSP_CONFIG_SYSTEM_SOUND_OUTPUT "PM_VSP_System_Sound_Output"

// VideoStreamProducer - video pipeline
#define VIDEOSTREAMER_CONSUMER "VideoStreamer_Consumer"
#define VIDEOSTREAMER_PRODUCER "VideoStreamer_Producer"

#define PM_VSP_CONFIG_VSAUDIOREADER_NAME "PM_VSP_VSAudioReader_Name"
#define PM_VSP_CONFIG_VSAUDIOENCODER_NAME "PM_VSP_VSAudioEncoder_Name"
#define PM_VSP_CONFIG_VSVIDEOREADER_NAME "PM_VSP_VSVideoReader_Name"
#define PM_VSP_CONFIG_VSVIDEOENCODER_NAME "PM_VSP_VSVideoEncoder_Name"
#define PM_VSP_CONFIG_VSPFILTER_NAME "PM_VSP_VSPFilter_Name"

#define PM_VSP_CONFIG_VSMUXER_NAME "PM_VSP_VSMUXER_Name"
#define PM_VSP_CONFIG_VSMAINTRANSMITTER_NAME "PM_VSP_VSMainTransmitter_Name"

#define PM_VSP_CONFIG_VSEXTRANSMITTER_NAME1 "PM_VSP_VSExtransmitter_Name1"
#define PM_VSP_CONFIG_VSEXTRANSMITTER_NAME2 "PM_VSP_VSExtransmitter_Name2"

// VideoStreamConsumer - video pipeline
#define PM_VSC_CONFIG_VSAUDIORECEIVER_NAME "PM_VSC_VSAudioReceiver_Name"
#define PM_VSC_CONFIG_VSAUDIODECODER_NAME "PM_VSC_VSAudioDecoder_Name"
#define PM_VSC_CONFIG_VSAUDIORENDER_NAME "PM_VSC_VSAudioRender_Name"

#define PM_VSC_CONFIG_VSVIDEORECEIVER_NAME "PM_VSC_VSVideoReceiver_Name"
#define PM_VSC_CONFIG_VSVIDEODECODER_NAME "PM_VSC_VSVideoDecoder_Name"
#define PM_VSC_CONFIG_VSVIDEORENDER_NAME "PM_VSC_VSVideoRender_Name"
#define PM_VSC_CONFIG_VSFILTER_NAME "PM_VSC_VSFilter_Name"

#define PM_VSC_CONFIG_VSDEMUXER_NAME "PM_VSC_VSDemuxer_Name"

#define PM_VS_CONFIG_AV_USING_SINGLE "PM_VS_AV_Using_Single"
#define PM_VS_CONFIG_MODE_PULL "PM_VS_Mode_Pull"
#define PM_VS_CONFIG_MODE_PUSH "PM_VS_Mode_Push"

#define PM_VS_CONFIG_AUDIO_MODE "PM_VS_Audio_Mode"
#define PM_VS_CONFIG_VIDEO_MODE "PM_VS_Video_Mode"

#define PM_VS_CONFIG_PACECONTROL_MODE "PM_VS_PaceControl_Mode"
#define PM_VS_CONFIG_PACECONTROL_SYNC_EACH 0
#define PM_VS_CONFIG_PACECONTROL_SYNC_SYNCFRAME 1
#define PM_VS_CONFIG_PACECONTROL_BPS 2
#define PM_VS_CONFIG_PACECONTROL_FPS 3
#define PM_VS_CONFIG_CURRENT_BPS "PM_VS_Current_BPS"
#define PM_VS_CONFIG_SCALE_DOWN_HIDPI "PM_VS_Scale_Down_HiDPI"

#define PM_VS_CONFIG_AUDIO_STREAM "PM_VS_Audio_Stream"
#define PM_VS_CONFIG_AUDIO_STREAM_PRESENCE 0
#define PM_VS_CONFIG_AUDIO_STREAM_NOT_PRESENCE 1
#define PM_VS_CONFIG_Stream_Type "PM_VS_CONFIG_Stream_Type"
#define PM_VS_CONFIG_Stream_Type_ES 0
#define PM_VS_CONFIG_Stream_Type_MUX 1

#define PM_VS_VideoStreamConfig "PM_VS_VideoStreamConfig"
#define PM_VS_CONFIG_VideoCodecID "PM_VS_CONFIG_VideoCodecID"
#define PM_VS_CONFIG_PixelFormat "PM_VS_CONFIG_PixelFormat"
#define PM_VS_CONFIG_VideoWidth "PM_VS_CONFIG_VideoWidth"
#define PM_VS_CONFIG_VideoHeight "PM_VS_CONFIG_VideoHeight"

#define PM_VS_AudioStreamConfig "PM_VS_AudioStreamConfig"
#define PM_VS_CONFIG_AudioCodecID "PM_VS_CONFIG_AudioCodecID"
#define PM_VS_CONFIG_Audio_SampleRate "PM_VS_CONFIG_Audio_SampleRate"
#define PM_VS_CONFIG_Audio_FrameSize "PM_VS_CONFIG_Audio_FrameSize"
#define PM_VS_CONFIG_Audio_Channels "PM_VS_CONFIG_Audio_Channels"
#define PM_VS_CONFIG_Audio_BitRate "PM_VS_CONFIG_Audio_BitRate"


#define PM_VS_CONFIG_VIDEOENCODER_OPTIONSET_PMPLAYER "PM_VS_VideoEncoder_OptionSet_PMPlayer"
#define PM_VS_CONFIG_VIDEOENCODER_OPTIONSET_OEM "PM_VS_VideoEncoder_OptionSet_OEM"

#define PM_VS_CONFIG_VIDEOENCODER_OPTION_FLAGS "PM_VS_VideoEncoder_Option_Flags"
#define PM_VS_CONFIG_VIDEOENCODER_OPTION_RATECONTROL "PM_VS_VideoEncoder_Option_RateControl"
#define PM_VS_CONFIG_VIDEOENCODER_OPTION_BITRATE "PM_VS_VideoEncoder_Option_BitRate"
#define PM_VS_CONFIG_VIDEOENCODER_OPTION_QP "PM_VS_VideoEncoder_Option_QP"
#define PM_VS_CONFIG_VIDEOENCODER_OPTION_IPFACTOR "PM_VS_VideoEncoder_Option_ip_factor"
#define PM_VS_CONFIG_VIDEOENCODER_OPTION_PBFACTOR "PM_VS_VideoEncoder_Option_pb_factor"
#define PM_VS_CONFIG_VIDEOENCODER_OPTION_RFCONSTANT "PM_VS_VideoEncoder_Option_rf_constant"
#define PM_VS_CONFIG_VIDEOENCODER_OPTION_VBVBUFFERSIZE "PM_VS_VideoEncoder_Option_vbv_buffer_size"
#define PM_VS_CONFIG_VIDEOENCODER_OPTION_VBVMAXBITRATE "PM_VS_VideoEncoder_Option_vbv_max_bitrate"
#define PM_VS_CONFIG_VIDEOENCODER_OPTION_INTRAREFRESH "PM_VS_VideoEncoder_Option_intra_refresh"
#define PM_VS_CONFIG_VIDEOENCODER_OPTION_DEBLOCKING "PM_VS_VideoEncoder_Option_deblocking"
#define PM_VS_CONFIG_VIDEOENCODER_OPTION_USING_SLICETHREAD "PM_VS_VideoEncoder_Option_bSliceThread"
#define PM_VS_CONFIG_VIDEOENCODER_OPTION_THREAD "PM_VS_VideoEncoder_Option_nThread"
#define PM_VS_CONFIG_VIDEOENCODER_OPTION_TUNE "PM_VS_VideoEncoder_Option_Tune"
#define PM_VS_CONFIG_VIDEOENCODER_OPTION_SPEED "PM_VS_VideoEncoder_Option_Speed"
#define PM_VS_CONFIG_VIDEOENCODER_OPTION_PROFILE "PM_VS_VideoEncoder_Option_Profile"

#define PM_VS_CONFIG_AUDIOREADER_OPTION_SILENCEPACKET "PM_VS_AudioReader_Option_SilencePacket"

#define  PM_VS_CONFIG_VIDEOENCODER_OPTION_FLAGS_None 0
#define  PM_VS_CONFIG_VIDEOENCODER_OPTION_FLAGS_RateControlMode (0x00000001 << 0)
#define  PM_VS_CONFIG_VIDEOENCODER_OPTION_FLAGS_bitrate (0x00000001 << 1)
#define  PM_VS_CONFIG_VIDEOENCODER_OPTION_FLAGS_qp_constant (0x00000001 << 2)
#define  PM_VS_CONFIG_VIDEOENCODER_OPTION_FLAGS_ip_factor (0x00000001 << 3)
#define  PM_VS_CONFIG_VIDEOENCODER_OPTION_FLAGS_pb_factor (0x00000001 << 4)
#define  PM_VS_CONFIG_VIDEOENCODER_OPTION_FLAGS_rf_constant (0x00000001 << 5)
#define  PM_VS_CONFIG_VIDEOENCODER_OPTION_FLAGS_vbv_buffer_size (0x00000001 << 6)
#define  PM_VS_CONFIG_VIDEOENCODER_OPTION_FLAGS_vbv_max_bitrate (0x00000001 << 7)
#define  PM_VS_CONFIG_VIDEOENCODER_OPTION_FLAGS_intra_refresh (0x00000001 << 8)
#define  PM_VS_CONFIG_VIDEOENCODER_OPTION_FLAGS_deblocking (0x00000001 << 9)
#define  PM_VS_CONFIG_VIDEOENCODER_OPTION_FLAGS_bSliceThread (0x00000001 << 10)
#define  PM_VS_CONFIG_VIDEOENCODER_OPTION_FLAGS_nThread (0x00000001 << 11)
#define  PM_VS_CONFIG_VIDEOENCODER_OPTION_FLAGS_TuneType (0x00000001 << 12)
#define  PM_VS_CONFIG_VIDEOENCODER_OPTION_FLAGS_SpeedType (0x00000001 << 13)
#define  PM_VS_CONFIG_VIDEOENCODER_OPTION_FLAGS_ProfileType  (0x00000001 << 14)

#define PM_VS_CONFIG_STREAM_MODE "PM_VS_Config_Stream_Mode"
#define PM_VS_CONFIG_STREAM_MODE_PRESENTATION 0
#define PM_VS_CONFIG_STREAM_MODE_VIDEO 1
#define PM_VS_CONFIG_CAL_STATISTICS "PM_VS_Config_Cal_Statistics"
#define PM_VS_CONFIG_ENABLE_RECORD "PM_VS_Config_EnableRecord"
#define PM_VS_CONFIG_START_RECORD "PM_VS_Config_StartRecord"
//#define PM_VS_CONFIG_STOP_RECORD "PM_VS_Config_StopRecord"
#define PM_VS_CONFIG_RECORD_FILE_PREFIX "PM_VS_Config_Record_FilePrefix"

#define PM_VS_CONFIG_STREAMER_REQUEST_FORCEI "PM_VS_Streamer_Request_ForceI"


#define PM_VS_CONFIG_ROWPITCH "VS_Config_RowPitch"

#define PM_VS_CONFIG_TAKE_SCREENSHOT "PM_VS_Config_Take_ScreenShot"
#define PM_VS_CONFIG_SCREENSHOT_FILE_PREFIX "PM_VS_Config_ScreenShot_FilePrefix"
#define PM_VS_CONFIG_FULLSCREEN "PM_VS_Config_FullScreen"


// component  name
#define VS_AUDIO_READER "VS_Audio_Reader"
#define VS_AUDIO_READER_PASSIVE "VS_Audio_Reader_Passive"
#define VS_ENCODER_AUDIO_CELT "VideoStream_Encoder_Audio_Celt"
#define VS_ENCODER_AUDIO_AAC "VideoStream_Encoder_Audio_AAC"

#define VS_AUDIO_RECEIVER_ACTIVE "VS_Audio_Receiver_Active"
#define VS_AUDIO_RECEIVER_PASSIVE "VS_Audio_Receiver_Passive"
#define VS_DECODER_CELT "Decoder_Celt"
#define VS_DECODER_AAC "Decoder_AAC"

#define VS_VIDEO_VideoReceiver "VS_VIDEO_VideoReceiver"
#define VS_VIDEO_FileStreamReceiver "VS_VIDEO_FileStreamReceiver"


#define VS_VIDEO_READER_MAC "VS_Video_Reader_Mac"
#define VS_VIDEO_READER_Generic "VS_Video_Reader_Generic"
#define VS_ENCODER_VIDEO_X264 "VideoStream_Encoder_Video_x264"
#define VS_ENCODER_VIDEO_MFX264 "VideoStream_Encoder_Video_MFX264"
#define VS_ENCODER_VIDEO_MJPEG "VideoStream_Encoder_Video_MJPEG"
#define VIDEO_DECODER_FFMPEG "Video_Decoder_ffmpeg"
#define VIDEO_DECODER_FFMPEG_PTS "Video_Decoder_ffmpeg_pts"
#define VIDEO_DECODER_MJPEG "Video_Decoder_MJPEG"

#define VSP_FILTER_IPP "VSP_Filter_IPP"
#define VSP_FILTER_IPPNV12 "VSP_Filter_IPPNV12"
#define VSP_FILTER_IPPPITCH "VSP_Filter_IPPPitch"
#define VSP_FILTER_YUV "VSP_Filter_YUV"
#define VSP_FILTER_ffmpeg_BGRA2YUV420 "VSP_FILTER_ffmpeg_BGRA2YUV420"

#define VSC_FILTER_IOS_YUV "VSC_Filter_iOS_YUV"
#define VSC_FILTER_IOS_YUV420_RGB565 "VSC_Filter_iOS_yuv420_rgb565"
#define VSC_FILTER_IPP_YUV420_BGRA "VSC_Filter_ipp_yuv420_bgra"

#define VS_MUX_FFMPEG "VS_Mux_ffmpeg"
#define VS_MUX_FFMPEG_THREAD "VS_Mux_ffmpeg_thread"

#define VS_TRANSMITTER_MUX_MPEGTS "VS_Transmitter_Mux_mpegts"

#define VS_Demux_ffmpeg "VS_Demux_ffmpeg"

#define VS_AUDIO_RENDER "VS_Audio_Render"
#define VS_AUDIO_PTSRENDER "VS_Audio_PTSRender"
#define VS_VIDEO_RENDER "VS_Video_Render"
#define VS_VIDEO_PTSRENDER "VS_Video_PTSRender"


#define VS_VIDEO_PACKETRENDER "VS_Video_PacketRender"
#define VS_AUDIO_PACKETRENDER "VS_Audio_PacketRender"
#define VS_VIDEO_PACKETFILERENDER "VS_Video_PacketFileRender"

// Custom input for components
#define VS_TRANSMITTER_MUX_FILENAME "VS_Transmitter_Mux_FileName"

#define VS_Demux_ffmpeg_CacheFileName "VS_Demux_ffmpeg_CacheFileName"


// Video stream utilities
#define VS_UTILITY_AVWRITER_FFMPEG "VS_Utility_AVWriter_ffmpeg"


//
// end of Video pipeline configuration
//

//
// AV related Features configuration
//
// Feature's components for android
#define DESKTOP_ANDROID		"Desktop_Android"

// Feature's components for linux
#define VIDEOFRAME_RENDER_RTD1185 "VideoFrame_Render_RTD1185"
#define DISPLAY_CONTROLLER_LINUX "Display_Controller_Linux"
#define DESKTOP_LINUX "Desktop_Linux"
#define CAM_LINUX "Cam_Linux"

#define VIDEOFRAME_RENDER_PACKETWRITTER "VideoFrame_Render_PacketWritter"

// Feature's components for windows

#define DESKTOP_WIN "Desktop_Win"
#define DISPLAY_CONTROLLER_WIN "Display_Controller_Win"
#define DESKTOP_WIN_OPTIONS_DISABLE_AERO "Desktop_Win_Options_DisableAero"
#define DESKTOP_WIN_OPTIONS_DISABLE_HWACCEL "Desktop_Win_Options_HW_Accel"

#define DESKTOP_FRAMEREADER_GDI "VideoFrame_Reader_GDI"
#define DESKTOP_FRAMEREADER_DXDUPLICATOR "VideoFrame_Reader_DXDuplicator"
#define DESKTOP_FRAMEREADER_D3D "VideoFrame_Reader_D3D"
#define DESKTOP_FRAMEREADER_D3DT "VideoFrame_Reader_D3D_thread"
#define AUDIO_READER_CORE_AUDIO "Audio_Reader_Core_Audio"
#define AUDIO_READER_MME "Audio_Reader_MME"
#define AUDIO_RENDER_WIN "Audio_Render_Win"
#define DISPLAY_CONTROLLER_WIN "Display_Controller_Win"
#define EXTENDEDDISPLAY_CONTROLLER_WIN "ExtendedDisplay_Controller_Win"

// Feature's components for iOS
#define VIDEO_FRAMEREADER_CAM_IOS "VideoFrameReader_Cam_iOS"
#define AUDIO_RENDER_IOS "Audio_Render_iOS"
#define AUDIO_RENDER_AUDIOQUEUE_AFS "Audio_Render_AudioQueue_AFS"
#define AUDIO_RENDER_AUDIOQUEUE "Audio_Render_AudioQueue"
#define VIDEOFRAME_RENDER_IOS "VideoFrame_Render_iOS"
#define VIDEO_FRAMEREADER_APP_IOS "VideoFrameReader_App_iOS"



#define VIDEO_FRAMEREADER_CAM_WIN "VideoFrameReader_Cam_Win"
#define VIDEO_FRAMEREADER_ONLYRX_WIN "VideoFrameReader_only_Win"


#define PM_AUDIO_DECODE_ACTIVE "PM_Audio_Decode_Active"
#define PM_FEATURE_REQUIREMENT "PM_Feature_Requirement"

#define PM_FEATURE_VIDEO_FPS "PM_Feature_Video_FPS"

// Feature's components for Mac
#define VIDEOFRAME_RENDER_MAC "VideoFrame_Render_Mac"
#define DESKTOP_FRAMEREADER_COREGRAPHIC "VideoFrameReader_Desktop_CoreGraphic"
#define DESKTOP_MAC "Desktop_Mac"

//
// File related Features configuration
//

#define PM_FEATURE_IC_CACHE_FILENAME "PM_Feature_IC_Cache_FileName"

// Feature's components for linux
#define IMAGE_RENDER_RTD1185 "Image_Render_RTD1185"

#define IMAGE_RENDER_Writer "Image_Render_Writer"


//
//
// ******** System utility related **********
//
//
#define PM_SYSUtils_Tick_Posix "PM_SYSUtils_Tick_Posix"
#define PM_SYSUtils_Tick_Apple "PM_SYSUtils_Tick_Apple"
#define PM_SYSUtils_Tick_Win "PM_SYSUtils_Tick_Win"

#define PM_Image_MJPEG_Encoder "PM_Image_MJPEG_Encoder"
#define PM_Image_MJPEG_Decoder "PM_Image_MJPEG_Decoder"

//
//
// ******** End - System utility **********
//
//


#endif 
