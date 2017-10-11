//
//  FeedController.swift
//  RssReader
//
//  Created by Admin on 11/10/2560 BE.
//  Copyright © 2560 BE Admin. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class FeedDetailController: UICollectionViewController {
    
    var entryUrl: String? {
        didSet {
            fetchFeed()
        }
    }
    
    var entries: [Entry]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.white
        
        //        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
        //            layout.estimatedItemSize = CGSizeMake(view.frame.width, 100)
        //        }
        
        self.collectionView!.register(EntryCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func fetchFeed() {
        let url = URL(string: "https://ajax.googleapis.com/ajax/services/feed/load?v=1.0&q=\(entryUrl!)")
        print(url)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error)
                return
            }
            
            do {
                
                let json = try(JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions())) as! [String: Any]
                
                let responseData = json["responseData"] as! [String: Any]?
                
                if let feedEntries = responseData?["feed"] ?? ["entries"] as? [String] {
                    self.entries = [Entry]()
                    for entryDictionary in feedEntries {
                        let title = entryDictionary["title"] as? String
                        let contentSnippet = entryDictionary["content"] as? String
                        let entry = Entry(title: title, contentSnippet: contentSnippet, url: nil)
                        self.entries?.append(entry)
                    }
                }
                
                DispatchQueue.main.async(execute: { () -> Void in
                    self.collectionView?.reloadData()
                })
                
                
            } catch let error {
                print(error)
            }
            
        }) .resume()
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = entries?.count {
            return count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let entryCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! EntryCell
        if let entry = entries?[indexPath.item], let title = entry.title, let contentSnippet = entry.contentSnippet {
            
            let options = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]
            
            do {
                entryCell.titleLabel.text = title
                entryCell.contentSnippetTextView.attributedText = try(NSAttributedString(data: contentSnippet.data(using: String.Encoding.unicode)!, options: options, documentAttributes: nil))
                entryCell.contentSnippetTextView.isScrollEnabled = true
                
            } catch let error {
                print("error creating attributed string", error)
            }
        }
        
        
        return entryCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        if let entry = entries?[indexPath.item], let contentSnippet = entry.contentSnippet {
            do {
                let text = try(NSAttributedString(data: contentSnippet.data(using: String.Encoding.unicode)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil))
                let size = text.boundingRect(with: CGSize(width: view.frame.width - 26, height: 2000), options: NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin), context: nil).size
                return CGSize(width: view.frame.width, height: size.height + 16)
            } catch let error {
                print(error)
            }
        }
        
        return CGSize(width: view.frame.width, height: 100)
    }
    
    
}

