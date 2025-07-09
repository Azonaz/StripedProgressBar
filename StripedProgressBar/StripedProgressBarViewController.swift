import UIKit

class StripedProgressBarViewController: UIViewController {
    private let backgroundView = UIView()
    private let progressView = UIView()
    private let pleaseWaitLabel = UILabel()
    private let percentLabel = UILabel()
    
    private var progress: CGFloat = 0.0
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupProgressBar()
        setupLabels()
        startProgressAnimation()
    }

    private func setupProgressBar() {
        backgroundView.backgroundColor = UIColor.black
        backgroundView.layer.cornerRadius = 9
        backgroundView.clipsToBounds = true
        view.addSubview(backgroundView)
        
        progressView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        progressView.layer.cornerRadius = 8
        progressView.clipsToBounds = true
        backgroundView.addSubview(progressView)
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backgroundView.widthAnchor.constraint(equalToConstant: 190),
            backgroundView.heightAnchor.constraint(equalToConstant: 20),
            progressView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 1),
            progressView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 1),
            progressView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -1),
            progressView.widthAnchor.constraint(equalToConstant: 0)
        ])
        addStripedOverlay(to: progressView)
    }
    
    private func setupLabels() {
        pleaseWaitLabel.translatesAutoresizingMaskIntoConstraints = false
        percentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(pleaseWaitLabel)
        view.addSubview(percentLabel)
        
        pleaseWaitLabel.text = "Please wait..."
        pleaseWaitLabel.textColor = UIColor.black
        
        percentLabel.text = "0%"
        percentLabel.textColor = UIColor.black
        
        NSLayoutConstraint.activate([
            pleaseWaitLabel.topAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: 12),
            pleaseWaitLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -30),
            
            percentLabel.centerYAnchor.constraint(equalTo: pleaseWaitLabel.centerYAnchor),
            percentLabel.leadingAnchor.constraint(equalTo: pleaseWaitLabel.trailingAnchor, constant: 8)
        ])
    }

    private func startProgressAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }

    private func updateProgress() {
        guard let widthConstraint = (progressView.constraints.first { $0.firstAttribute == .width }) else { return }
        let maxWidth: CGFloat = 187
        if progress >= 1.0 {
            timer?.invalidate()
            return
        }
        progress += 0.005
        widthConstraint.constant = maxWidth * progress

        UIView.animate(withDuration: 0.02) {
            self.view.layoutIfNeeded()
            if let stripeLayer = self.progressView.layer.sublayers?.first(where: { $0.name == "StripeLayer" }) {
                stripeLayer.frame = self.progressView.bounds
            }
        }

        let percentage = Int(progress * 100)
        let roundedPercentage = (percentage / 5) * 5
        percentLabel.text = "\(roundedPercentage)%"
    }

    private func addStripedOverlay(to view: UIView) {
        let stripeWidth: CGFloat = 4
        let stripeSpacing: CGFloat = 10
        let stripeColor = UIColor.black.withAlphaComponent(0.5)
        
        let stripeSize = CGSize(width: stripeWidth + stripeSpacing, height: 20)
        
        UIGraphicsBeginImageContextWithOptions(stripeSize, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.clear.cgColor)
            context.fill(CGRect(origin: .zero, size: stripeSize))
            
            context.setFillColor(stripeColor.cgColor)

            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: stripeWidth, y: 0))
            path.addLine(to: CGPoint(x: stripeWidth + stripeSpacing, y: stripeSize.height))
            path.addLine(to: CGPoint(x: stripeSpacing, y: stripeSize.height))
            path.close()

            path.fill()
        }
        
        guard let stripeImage = UIGraphicsGetImageFromCurrentImageContext() else { return }
        UIGraphicsEndImageContext()
        
        let stripeLayer = CALayer()
        stripeLayer.name = "StripeLayer"
        stripeLayer.frame = view.bounds
        stripeLayer.backgroundColor = UIColor(patternImage: stripeImage).cgColor
        stripeLayer.cornerRadius = view.layer.cornerRadius
        stripeLayer.masksToBounds = true

        view.layer.sublayers?.removeAll(where: { $0.name == "StripeLayer" })
        view.layer.addSublayer(stripeLayer)
    }
}
