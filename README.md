# SubscriptionFetch

## Overview  
This demo addresses the need for attachment data to be fetched automatically when observed in 
a DittoDocument sync. This initial version is made available as a draft. Refinements are planned 
for some optimization and developer ergonomic features. Forks and pull requests are welcome.  

As is, this example code implements a class, `DittoAttachmentSubscription`, that initializes with a 
`DittoSubscription` instance and property name/key and then observes updates in the subscribed 
collection. Its `AttachmentAutoFetcher` property instance takes an array of `DittoDocument`s and  
fetches attachments where the value for the token key is non-nil, using a concurrent threading queue. 

An example of fetching attachment data on user demand can be found in the 
[iOS Chat app demo project](https://github.com/getditto/demoapp-chat/tree/main/iOS).  

## Setup and Run    
1. Clone this repo to a location on your machine, and open in Xcode.    
2. Navigate to the project `Signing & Capabilities` tab and modify the `Team and Bundle Identifier` 
settings to your Apple developer account credentials to provision building to your device.    
3. In your [Ditto portal](https://portal.ditto.live), create an app to generate an App ID and 
playground token.  
4. In Terminal, run `cp .env.template .env` at the Xcode project root directory.     
5. Edit `.env` to add appID and playground token values from the portal as environment variables. 
Also add the collection name and the attachment token property name/key - used when adding an 
attachment to a DittoDocument.  
  
Example: 
```  
DITTO_APP_ID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX 
DITTO_PLAYGROUND_TOKEN=XXXXXXXX-XXXX-XXXX-XXXXXXXXXXXX 
DITTO_COLLECTION_NAME=my_attachments_collection_name 
DITTO_ATTACHMENT_TOKEN_KEY=my_attachment_property_name
```

6. Clean (**Command + Shift + K**), then build (**Command + B**). This will generate `Env.swift`.  
(repeat if necessary)  
