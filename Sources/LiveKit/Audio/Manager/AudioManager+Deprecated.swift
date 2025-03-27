/*
 * Copyright 2025 LiveKit
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#if swift(>=5.9)
internal import LiveKitWebRTC
#else
@_implementationOnly import LiveKitWebRTC
#endif

@objc
public enum MicrophoneMuteMode: Int {
    /// Uses `AVAudioEngine`'s `isVoiceProcessingInputMuted` internally.
    /// This is fast, and muted speaker detection works. However, iOS will play a sound effect.
    case voiceProcessing
    /// Restarts the internal `AVAudioEngine` without mic input when muted.
    /// This is slower, and muted speaker detection does not work. No sound effect is played.
    case restartEngine
    case unknown
}

extension RTCAudioEngineMuteMode {
    func toLKType() -> MicrophoneMuteMode {
        switch self {
        case .voiceProcessing: return .voiceProcessing
        case .restartEngine: return .restartEngine
        case .unknown: return .unknown
        @unknown default: return .unknown
        }
    }
}

extension MicrophoneMuteMode {
    func toRTCType() -> RTCAudioEngineMuteMode {
        switch self {
        case .unknown: return .unknown
        case .voiceProcessing: return .voiceProcessing
        case .restartEngine: return .restartEngine
        }
    }
}

public extension AudioManager {
    var muteMode: MicrophoneMuteMode {
        RTC.audioDeviceModule.muteMode.toLKType()
    }

    func set(muteMode: MicrophoneMuteMode) throws {
        guard muteMode != .unknown else {
            throw LiveKitError(.invalidState, message: "Unsupported mute mode specified")
        }
        let result = RTC.audioDeviceModule.setMuteMode(muteMode.toRTCType())
        try checkAdmResult(code: result)
    }
}

// MARK: - Deprecated

public extension AudioManager {
    /// Set to `true` to enable legacy mic mute mode.
    ///
    /// - Default: Uses `AVAudioEngine`'s `isVoiceProcessingInputMuted` internally.
    ///   This is fast, and muted speaker detection works. However, iOS will play a sound effect.
    /// - Legacy: Restarts the internal `AVAudioEngine` without mic input when muted.
    ///   This is slower, and muted speaker detection does not work. No sound effect is played.
    @available(*, deprecated, message: "Use `muteMode` instead")
    var isLegacyMuteMode: Bool { RTC.audioDeviceModule.muteMode == .restartEngine }

    @available(*, deprecated, message: "Use `set(muteMode:)` instead")
    func setLegacyMuteMode(_ enabled: Bool) throws {
        let mode: RTCAudioEngineMuteMode = enabled ? .restartEngine : .voiceProcessing
        let result = RTC.audioDeviceModule.setMuteMode(mode)
        try checkAdmResult(code: result)
    }
}
