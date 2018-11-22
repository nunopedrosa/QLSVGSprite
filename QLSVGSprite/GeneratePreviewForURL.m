#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#import <Cocoa/Cocoa.h>

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    @autoreleasepool {
        NSError *theErr = nil;
        NSURL *myURL = (__bridge NSURL *)url;
        
        // Load document data using NSStrings house methods
        NSStringEncoding stringEncoding;
        NSString *fileString = [NSString stringWithContentsOfURL:myURL usedEncoding:&stringEncoding error:&theErr];
        
        // We could not open the file, probably unknown encoding; try ISO-8859-1
        if (!fileString) {
            stringEncoding = NSISOLatin1StringEncoding;
            fileString = [NSString stringWithContentsOfURL:myURL encoding:stringEncoding error:&theErr];
            // Still no success, give up
            if (!fileString) {
                if (nil != theErr) {
                    NSLog(@"Error opening the file: %@", theErr);
                }
                return noErr;
            }
        }
        
        // Parse the data if still interested in the preview
        if (false == QLPreviewRequestIsCancelled(preview)) {
            
            // Create HTML of the data if still interested in the preview
            if (false == QLPreviewRequestIsCancelled(preview)) {
                NSMutableString *html = [[NSMutableString alloc] initWithString:@""];
                if ([fileString containsString:@"<symbol"]) {
                
                // compose the html
                [html appendString:@"<!DOCTYPE html>\n"];
                [html appendString:@"<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\"><head>\n"];
                [html appendString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /></head>\n"];
                [html appendString:@"<body style='background-image:url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAHklEQVR4AWOor6+XQsfuBT4M6HhIKMQiiFXzUFAIAGeeghVA3mpTAAAAAElFTkSuQmCC)'><center>"];
                NSError *error = NULL;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(<symbol.*?symbol>)"
                                                                                       options:(NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators)
                                                                                         error:&error];
                NSRegularExpression *regexSym = [NSRegularExpression regularExpressionWithPattern:@"<symbol\\s+id=[\"'](.*?)[\"']\\s+viewBox=[\"'](.*?)[\"'].*?>(.*?)<.symbol"
                                                                                          options:(NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators)
                                                                                            error:&error];

                NSArray *matches = [regex matchesInString:fileString
                                                  options:0
                                                    range:NSMakeRange(0, [fileString length])];
                for (NSTextCheckingResult *match in matches) {
                    NSRange matchRange = [match range];
                    NSString *symbol= [fileString substringWithRange:matchRange];
                    NSArray *matchesSym = [regexSym matchesInString:symbol
                                                            options:0
                                                              range:NSMakeRange(0, [symbol length])];
                    for (NSTextCheckingResult *matchSym in matchesSym) {
                        NSString *id= [symbol substringWithRange:[matchSym rangeAtIndex:1]];
                        NSString *vBox= [symbol substringWithRange:[matchSym rangeAtIndex:2]];
                        NSString *paths= [symbol substringWithRange:[matchSym rangeAtIndex:3]];
                        [html appendString:@"<div style='border:1px solid #AAAAAA; float:left; width:14%; height:100px; text-align:center; justify-content: center;'>"];
                        [html appendString:id];
                        [html appendString:@"<div style='width:48px; margin: 0 auto'>"];
                        [html appendString:@"<svg class='nav__icon color-grey-dark-3' viewBox='"];
                        [html appendString:vBox];
                        [html appendString:@"'>"];
                        [html appendString:paths];
                        [html appendString:@"</svg></div></div>"];
                    }
                }
                [html appendString:@"</center></body></html>"];
                } else {
                
                    [html appendFormat:@"<html><body style='background-image:url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAHklEQVR4AWOor6+XQsfuBT4M6HhIKMQiiFXzUFAIAGeeghVA3mpTAAAAAElFTkSuQmCC)'><center><img style='vertical-align: middle;height:98%%;max-width:98%%' src='data:image/svg+xml;utf8,%@'></center></body></html>", [fileString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];

                   // [html appendFormat:@"<html><body bgcolor='#EEEEEE'><center><img style='vertical-align: middle;height:98%%;max-width:98%%' src='data:image/svg+xml;utf8,%@'></center></body></html>", [fileString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
                }
                // feed the HTML
                CFDictionaryRef properties = (__bridge CFDictionaryRef)@{};
                QLPreviewRequestSetDataRepresentation(preview,
                                                      (__bridge CFDataRef)[html dataUsingEncoding:stringEncoding],
                                                      kUTTypeHTML,
                                                      properties
                                                      );
            }
        }
    }
    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}
