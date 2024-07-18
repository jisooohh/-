import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var selectedImages: [UIImage?] = [nil, nil, nil, nil]
    @State private var showingCamera = false
    @State private var showingPhotoPicker = false
    @State private var filterIntensity: Double = 0.5
    @State private var currentFilter: FilterType = .none
    @State private var isQuadMode = false
    @State private var quadImages: [UIImage] = []
    @State private var currentQuadIndex = 0

    var body: some View {
        NavigationView {
            VStack {
                if isQuadMode {
                    QuadImageView(images: selectedImages)
                } else if let image = selectedImages[0] {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    Text("No Image Selected")
                }
                
                HStack {
                    Button("Camera") {
                        showingCamera = true
                    }
                    Button("Photo Library") {
                        showingPhotoPicker = true
                    }
                }
                
                Picker("Filter", selection: $currentFilter) {
                    ForEach(FilterType.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Slider(value: $filterIntensity, in: 0...1)
                    .onChange(of: filterIntensity) {
                        applyFilter()
                    }
                
                Toggle("Quad Mode", isOn: $isQuadMode)
                
                if isQuadMode {
                    HStack {
                        ForEach(0..<4) { index in
                            Button("Image \(index + 1)") {
                                currentQuadIndex = index
                                showingPhotoPicker = true
                            }
                        }
                    }
                } else {
                    Button("Take Photo") {
                        showingCamera = true
                    }
                }
            }
            .sheet(isPresented: $showingCamera) {
                CameraView(image: $selectedImages[currentQuadIndex]) { image in
                    if isQuadMode {
                        quadImages.append(image)
                    } else {
                        selectedImages[currentQuadIndex] = image
                    }
                }
            }
            .sheet(isPresented: $showingPhotoPicker) {
                PhotoPicker(image: $selectedImages[currentQuadIndex])
            }
            .onChange(of: selectedImages[0]) {
                applyFilter()
            }
        }
    }
    
    func applyFilter() {
        let context = CIContext()
        
        for i in 0..<selectedImages.count {
            guard let inputImage = selectedImages[i],
                  let ciImage = CIImage(image: inputImage) else { continue }
            
            var outputImage: CIImage?
            
            switch currentFilter {
            case .sepia:
                guard let filter = CIFilter(name: "CISepiaTone") else { continue }
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                filter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
                outputImage = filter.outputImage
                
            case .mono:
                guard let filter = CIFilter(name: "CIPhotoEffectMono") else { continue }
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                outputImage = filter.outputImage
                
            case .none:
                outputImage = ciImage
            }
            
            if let outputImage = outputImage,
               let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                selectedImages[i] = UIImage(cgImage: cgImage)
            }
        }
    }
    
    func combineQuadImages() -> UIImage? {
        let size = CGSize(width: 400, height: 400)
        UIGraphicsBeginImageContext(size)
        
        for (index, image) in selectedImages.enumerated() {
            if let image = image {
                let rect = CGRect(x: CGFloat(index % 2) * 200,
                                  y: CGFloat(index / 2) * 200,
                                  width: 200, height: 200)
                image.draw(in: rect)
            }
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}

enum FilterType: String, CaseIterable {
    case none = "None"
    case sepia = "Sepia"
    case mono = "Mono"
}
