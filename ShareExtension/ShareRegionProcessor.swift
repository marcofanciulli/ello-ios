////
///  ShareRegionProcessor.swift
//

import Foundation

public class ShareRegionProcessor {

    public init(){}

    public static func prepContent(contentText: String, itemPreviews: [ExtensionItemPreview]) -> [PostEditingService.PostContentRegion] {
        var content: [PostEditingService.PostContentRegion] = []

        let cleanedText = contentText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if cleanedText.characters.count > 0 {
            let region = PostEditingService.PostContentRegion.Text(cleanedText)
            let exists = content.any {$0 == region}
            if !exists {
                content.append(region)
            }
        }

        for preview in itemPreviews {
            if let gifData = preview.gifData, image = preview.image {
                let region = PostEditingService.PostContentRegion.ImageData(image, gifData, "image/gif")
                let exists = content.any {$0 == region}
                if !exists {
                    content.append(region)
                }
            }
            else if let image = preview.image {
                let region = PostEditingService.PostContentRegion.Image(image)
                let exists = content.any {$0 == region}
                if !exists {
                    content.append(region)
                }
            }

            if let text = preview.text {
                let region = PostEditingService.PostContentRegion.Text(text)
                let exists = content.any {$0 == region}
                if !exists {
                    content.append(region)
                }
            }
        }

        return content
    }
}
