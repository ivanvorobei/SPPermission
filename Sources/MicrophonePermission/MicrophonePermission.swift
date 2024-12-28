// The MIT License (MIT)
// Copyright © 2022 Sparrow Code LTD (https://sparrowcode.io, hello@sparrowcode.io)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if PERMISSIONSKIT_SPM
import PermissionsKit
#endif

#if (os(iOS) || os(macOS)) && PERMISSIONSKIT_MICROPHONE
import Foundation
import AVFoundation

public extension Permission {
    
    static var microphone: MicrophonePermission {
        return MicrophonePermission()
    }
}

public class MicrophonePermission: Permission {
    
    open override var kind: Permission.Kind { .microphone }
    open var usageDescriptionKey: String? { "NSMicrophoneUsageDescription" }
    
    public override var status: Permission.Status {
        #if os(iOS)
        switch  AVAudioSession.sharedInstance().recordPermission {
        case .granted: return .authorized
        case .denied: return .denied
        case .undetermined: return .notDetermined
        @unknown default: return .denied
        }
        #elseif os(macOS)
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
            case .denied: return .denied
            case .notDetermined: return .notDetermined
            case .restricted: return .denied
            case .authorized: return .authorized
            @unknown default: return .denied
        }
        #endif
    }
    
    public override func request(completion: @escaping () -> Void) {
        #if os(iOS)
        AVAudioSession.sharedInstance().requestRecordPermission {
            granted in
            DispatchQueue.main.async {
                completion()
            }
        }
        #elseif os(macOS)
        AVCaptureDevice.requestAccess(for: .audio) { _ in
            DispatchQueue.main.async {
                completion()
            }
        }
        #endif
    }
}
#endif
