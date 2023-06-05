//
//  YoutubePlayerWebView.swift
//  TumenCity
//
//  Created by Павел Кай on 05.06.2023.
//

import WebKit

final class YoutubePlayerWebView: UIView {
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 15
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadVideo(_ url: URL) {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = false
  
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        
        addSubview(webView)
        
        webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        activityIndicator.startAnimating()
        
        DispatchQueue.main.async {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
}

extension YoutubePlayerWebView: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
}
