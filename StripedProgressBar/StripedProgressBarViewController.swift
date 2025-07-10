import UIKit

class StripedProgressBarViewController: UIViewController {
    private let backgroundView = UIView()
    private let progressView = UIView()
    private let loadLabel = UILabel()
    private let percentLabel = UILabel()
    private let labelStack = UIStackView()
    
    private var progress: CGFloat = 0.0
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupProgressBar()
        setupLabels()
        startProgressAnimation()
    }
    
    /// Sets up the base progress bar and its animated filling view
    private func setupProgressBar() {
        // Set up static background view (250x30) with rounded corners
        backgroundView.backgroundColor = UIColor.black
        backgroundView.layer.cornerRadius = 15
        backgroundView.clipsToBounds = true
        view.addSubview(backgroundView)
        
        // Set up progress view (dynamic width, fills up the backgroundView)
        progressView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        progressView.layer.cornerRadius = 13 // Slightly smaller to match inner area and fit within rounded background
        progressView.clipsToBounds = true
        backgroundView.addSubview(progressView)
        
        // Layout constraints for positioning and sizing
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backgroundView.widthAnchor.constraint(equalToConstant: 250),
            backgroundView.heightAnchor.constraint(equalToConstant: 30),
            // progressView has 2pt padding on each side, initial width = 0
            progressView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 2),
            progressView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 2),
            progressView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -2),
            progressView.widthAnchor.constraint(equalToConstant: 0)
        ])
        
        // Add diagonal striped overlay pattern to the progressView
        addStripedOverlay(to: progressView)
    }
    
    /// Configures the loading and percentage labels inside a horizontal stack
    private func setupLabels() {
        loadLabel.text = "Loading..."
        loadLabel.textColor = .black
        loadLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        loadLabel.textAlignment = .left
        
        percentLabel.text = "0%"
        percentLabel.textColor = .black
        percentLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        percentLabel.textAlignment = .right
        
        labelStack.axis = .horizontal
        labelStack.spacing = 3
        labelStack.alignment = .fill
        labelStack.addArrangedSubview(loadLabel)
        labelStack.addArrangedSubview(percentLabel)
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(labelStack)
        
        NSLayoutConstraint.activate([
            labelStack.topAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: 30),
            labelStack.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            labelStack.widthAnchor.constraint(equalToConstant: 210)
        ])
    }
    
    /// Starts a timer to animate the progress bar
    private func startProgressAnimation() {
        // Start timer that updates progress every 0.03 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }
    
    /// Updates the progress bar's width and label text incrementally
    private func updateProgress() {
        // Find the width constraint of the progressView
        guard let widthConstraint = (progressView.constraints.first { $0.firstAttribute == .width }) else { return }
        
        let maxWidth: CGFloat = 246 // Max width (250 - 2pt left - 2pt right)
        
        if progress >= 1.0 {
            timer?.invalidate()
            return
        }
        
        progress += 0.005
        widthConstraint.constant = maxWidth * progress
        
        // Animate layout and adjust stripe overlay frame
        UIView.animate(withDuration: 0.02) {
            self.view.layoutIfNeeded()
            if let stripeLayer = self.progressView.layer.sublayers?.first(where: { $0.name == "StripeLayer" }) {
                stripeLayer.frame = self.progressView.bounds
            }
        }
        
        // Update percentage label (rounded to nearest 5%)
        let percentage = Int(progress * 100)
        let roundedPercentage = (percentage / 5) * 5
        percentLabel.text = "\(roundedPercentage)%"
    }
    
    /// Adds a repeating diagonal stripe overlay to the given view
    private func addStripedOverlay(to view: UIView) {
        let stripeWidth: CGFloat = 5 // Width of each stripe
        let stripeSpacing: CGFloat = 15 // Space between stripes
        let stripeColor = UIColor.black.withAlphaComponent(0.5)
        
        // Define size of the repeating pattern image
        let stripeSize = CGSize(width: stripeWidth + stripeSpacing, height: 30)
        
        // Start image context to draw a single stripe segment
        UIGraphicsBeginImageContextWithOptions(stripeSize, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.clear.cgColor)
            context.fill(CGRect(origin: .zero, size: stripeSize))
            
            context.setFillColor(stripeColor.cgColor)
            
            // Draw a diagonal stripe using a trapezoid shape
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: stripeWidth, y: 0))
            path.addLine(to: CGPoint(x: stripeWidth + stripeSpacing, y: stripeSize.height))
            path.addLine(to: CGPoint(x: stripeSpacing, y: stripeSize.height))
            path.close()
            
            path.fill()
        }
        
        // Extract pattern image from context
        guard let stripeImage = UIGraphicsGetImageFromCurrentImageContext() else { return }
        UIGraphicsEndImageContext()
        
        // Create a layer that fills with the stripe pattern
        let stripeLayer = CALayer()
        stripeLayer.name = "StripeLayer"
        stripeLayer.frame = view.bounds
        stripeLayer.backgroundColor = UIColor(patternImage: stripeImage).cgColor
        stripeLayer.cornerRadius = view.layer.cornerRadius
        stripeLayer.masksToBounds = true
        
        // Remove any previous stripe layers (if re-adding)
        view.layer.sublayers?.removeAll(where: { $0.name == "StripeLayer" })
        view.layer.addSublayer(stripeLayer)
    }
}
