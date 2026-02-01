Now I'll generate the comprehensive report based on all the research gathered.

***

# Why Apple Doesn't Offer Native iMessage Export: A Technical and Strategic Deep Dive

Apple's iMessage has become one of the most widely used messaging platforms globally, with over 2 billion users and near-complete penetration among iPhone owners in markets like the United States. Yet despite its ubiquity and the obvious user need to archive or export message histories—for legal proceedings, sentimental preservation, or simple data portability—Apple has never provided a native export feature. This absence is not an oversight. It represents a confluence of strategic business decisions, technical architecture constraints, competitive positioning, and legal complexity that collectively make message export functionality incompatible with Apple's broader ecosystem strategy.[1][2]

## The Strategic Imperative: iMessage as Ecosystem Lock-In

### The Walled Garden Architecture

Apple's approach to iMessage export is inseparable from its broader "walled garden" strategy—a multi-layered ecosystem designed to create switching costs that retain customers within Apple's product universe. This strategy has proven extraordinarily effective: Apple's installed base exceeds 2.4 billion active devices, and its Services segment generates $27.4 billion per quarter with gross margins near 75%, compared to just 39.3% for hardware. iMessage functions as a critical retention mechanism within this architecture, particularly among younger demographics where iPhone ownership reaches 87% in the United States.[3][4][5][6][7][8][1]

The messaging platform creates what economists call "network effects"—the value increases as more users adopt the technology. When an iPhone user messages another iPhone user, conversations appear in distinctive blue bubbles with rich features: read receipts, typing indicators, high-resolution media sharing, reactions, and end-to-end encryption. Messages to non-iPhone users—primarily Android—degrade to SMS/MMS, appearing in green bubbles with severely limited functionality. This color distinction is not accidental; research indicates Apple deliberately designed the green to be "harsher on the eyes," creating a visual hierarchy that positions iMessage as premium and everything else as inferior.[2][5][9][10][11][1]

### The Teen Social Dynamics Phenomenon

This design choice has profound social consequences, particularly among teenagers and young adults. Multiple studies document "green bubble shaming," where Android users report being excluded from group chats, experiencing negative social stigma, and even being "ghosted" due to their device choice. Tim Cook himself acknowledged this dynamic in emails revealed during the Epic v. Apple antitrust trial, where he described Android compatibility (specifically RCS adoption) as an "obstacle" to users attempting to migrate away from iPhone.[5][1][2][3]

The Wall Street Journal reported in 2022 that teens "dread the green text bubble," with the phenomenon driving substantial iPhone adoption among younger users specifically to avoid social exclusion. This creates a self-reinforcing cycle: as iPhone penetration increases within social groups, the pressure on remaining Android users intensifies, driving further adoption and strengthening Apple's competitive moat.[4][6][2]

### Services Revenue and Recurring Income Streams

Beyond hardware sales, Apple has systematically transformed into a services company. The Services segment—encompassing iCloud, Apple Music, Apple TV+, App Store, and others—represents Apple's fastest-growing, highest-margin business. iMessage supports this transformation in multiple ways:[8][12]

First, the platform encourages iCloud storage purchases. When Messages in iCloud is enabled, all message history and attachments sync across devices, consuming iCloud storage. Users receive only 5GB free storage, which quickly fills with message attachments, photos, and backups, creating pressure to purchase additional capacity. Second, the messaging experience integrates tightly with other paid services—Apple Music links preview in messages, Apple Pay facilitates transactions, and FaceTime enables video calling.[13][14][15][16][17][8]

Providing native export functionality would undermine these dynamics. If users could easily extract their entire message history and transfer it to another platform or device ecosystem, one of the most powerful switching costs would evaporate. The technical effort to archive messages across years of conversations, maintain formatting, preserve attachments, and enable searchability creates substantial friction that keeps users within Apple's ecosystem even when they might otherwise switch devices.[6][4]

## Technical Architecture: Why Export Is Genuinely Complex

While strategic considerations explain *why* Apple doesn't prioritize export, the technical architecture of iMessage makes implementation genuinely complex—though certainly not impossible for a company of Apple's engineering capability.

### End-to-End Encryption and the Device-Key Model

iMessage employs a sophisticated end-to-end encryption (E2EE) architecture fundamentally different from traditional messaging systems. Unlike platforms where messages pass through centralized servers that could theoretically decrypt content, iMessage's security model ensures only sender and recipient devices can read message content—not even Apple can access plaintext messages.[18][19][20][21][22]

This works through a device-based key system:

1. **Key Generation**: Each device generates its own public/private key pair locally when first registered for iMessage. The private key never leaves the device and is protected by the Secure Enclave, Apple's hardware-based security module.[20][23][24][25]

2. **Key Distribution**: Public keys are uploaded to Apple's Identity Directory Service (IDS), which maps phone numbers and email addresses to the public keys for all registered devices. The IDS also stores each device's Apple Push Notification Service (APNs) address for message routing.[22][25][26][27]

3. **Message Encryption**: When you send an iMessage, your device queries the IDS for the recipient's public keys—one for each of their registered devices. Your device then creates separate encrypted copies of the message for each recipient device. If you message someone with five devices (iPhone, iPad, MacBook, Apple Watch, and iMac), your device creates and encrypts five individual copies.[23][24]

4. **Transmission and Decryption**: Each encrypted message is routed through APNs to the appropriate device. Only that device's private key can decrypt its copy of the message.[24][27][22][23]

### The PQ3 Protocol: Post-Quantum Security

In February 2024, Apple upgraded iMessage to PQ3 (Post-Quantum 3), which Apple claims provides "the strongest security properties of any at-scale messaging protocol in the world". PQ3 implements a hybrid cryptographic approach combining traditional Elliptic Curve Cryptography (ECC) with post-quantum algorithms (specifically Kyber-1024, selected by NIST as a module-lattice-based key-encapsulation mechanism).[28][29][18][20]

This protocol operates in three levels:

- **Level 0**: No encryption (e.g., SMS)
- **Level 1**: E2EE using classical cryptography (e.g., original iMessage, WhatsApp without PQXDH)
- **Level 2**: Post-quantum secure key establishment (e.g., Signal with PQXDH)
- **Level 3**: Post-quantum security for both key establishment and ongoing message exchange with periodic key rotation[18][20][28]

PQ3 automatically "ratchets" encryption keys forward with each message exchange, limiting the number of messages compromised even if a specific key is broken. This "ratcheting" mechanism adds another layer of complexity to any export system, as messages encrypted under different key states would need special handling.[20][28]

### Implications for Export Functionality

This architecture creates genuine technical challenges for export:

**Decryption Authority**: Because private keys never leave devices and Apple doesn't retain decryption capability, any export function must execute on-device where private keys reside. This contrasts with cloud-first services where providers could generate exports server-side.[21][22][24]

**Multi-Device Synchronization**: A complete message history requires aggregating data from all devices a user has ever registered. Messages sent to Device A while Device B was offline may never reach Device B, creating fragmented histories across devices.[30][31][23][24]

**Key Management Complexity**: With keys rotating continuously under PQ3, an export system would need to maintain access to historical keys or re-decrypt messages using current keys—both technically complex operations.[28][20]

**Attachment Handling**: Attachments follow a separate storage path from message text, often offloaded to iCloud when local storage fills. Reconstructing complete conversations requires pulling text from local databases and attachments from cloud storage, coordinating across multiple storage layers.[16][17][32]

However, it's critical to note: these challenges are *complex*, not *impossible*. Third-party tools like iMazing, PhoneView, and TouchCopy successfully export iMessages by accessing the local SQLite database directly. Open-source projects like `imessage-exporter` demonstrate that the core technical challenge is solved. Apple possesses vastly greater engineering resources than these third-party developers. The technical complexity provides plausible deniability for the absence of export, but strategic considerations are the true barrier.[32][33][34][35][36]

## How iMessage Differs from SMS and RCS

Understanding why Apple doesn't offer export requires understanding how fundamentally different iMessage is from alternative messaging protocols—and why those differences create competitive advantages worth protecting.

### SMS: The 1990s Legacy Protocol

Short Message Service (SMS) dates to the 1980s GSM standardization process, with technical specifications finalized in the early 1990s. The protocol was designed to "fit in-between" other signaling protocols, utilizing control channels in cellular networks rather than voice or data channels. This architectural decision imposed severe constraints:[37][38]

**Character Limits**: SMS supports 160 characters when using GSM-7 encoding (a 7-bit character set of 128 characters), or just 70 characters when using UCS-2 encoding for emoji, non-Latin scripts, or extended characters. Messages exceeding these limits are segmented, with each segment including metadata headers that reduce available character space to 153 (GSM-7) or 67 (UCS-2) characters per segment.[38][39][40]

**No Encryption**: SMS messages transit networks in plaintext, visible to carriers and vulnerable to interception. Law enforcement regularly requests SMS records from carriers without device access.[10][19][37]

**No Rich Media**: Original SMS supports only text. MMS (Multimedia Messaging Service) was added later to support images and video, but with severe compression and quality degradation.[9][10]

**Network Dependency**: SMS requires cellular network connectivity and cannot function over Wi-Fi alone.[37]

**Cost Structure**: SMS historically incurred per-message charges, though unlimited texting is now common in many markets.[11]

### RCS: The Fragmented Upgrade

Rich Communication Services (RCS) represents the mobile industry's attempt to modernize messaging for the IP era. Specified by the GSM Association starting in 2007, RCS supports:[9][10][37]

- Messages up to 1,600 characters without segmentation[39][41]
- High-resolution photo and video sharing
- Read receipts and typing indicators  
- Group messaging with advanced features
- Transmission over Wi-Fi or mobile data networks[10][9]

However, RCS suffers from fragmentation challenges that iMessage doesn't face:

**Inconsistent Implementation**: RCS depends on carrier deployment and device manufacturer support. Some carriers use outdated RCS versions; others don't support it at all. This creates unpredictable user experiences where features work inconsistently.[9][10]

**Encryption Limitations**: Google Messages provides E2EE for one-to-one RCS conversations between Android users, but not for group chats or business messages. This inconsistency means security guarantees vary by conversation type.[19][10][9]

**Platform Fragmentation**: RCS works primarily on Android devices. Apple announced plans to support RCS in late 2024 but has not implemented full E2EE for RCS messages, meaning iPhone-to-Android messages remain unencrypted.[42][9]

**Fallback Complexity**: When RCS fails—due to lack of support, poor data connectivity, or temporary service issues—messages automatically fall back to SMS, stripping away all rich features. Users often don't realize when fallback occurs, creating confusion about capability availability.[43][37][9]

### iMessage: The Controlled Ecosystem Advantage

iMessage's technical advantages stem from Apple's control over the entire stack—hardware, operating system, and service infrastructure:[4][6]

**Consistent E2EE**: Every iMessage conversation uses end-to-end encryption by default, regardless of conversation type (one-to-one, group, business). There are no exceptions, fallbacks, or degraded security modes within the iMessage ecosystem.[19][18][20]

**Unlimited Size**: Messages can be arbitrarily long without segmentation. Large media files transmit at full quality without SMS-style compression.[10][9]

**Instant Synchronization**: Messages sync across all Apple devices in near-real-time when connected to the internet. Start a conversation on iPhone, continue on iPad, finish on Mac seamlessly.[44][45][13]

**Rich Interactive Features**: Reactions, message effects, inline replies, Memoji, stickers, Apple Pay integration, and more—all guaranteed to work consistently because Apple controls both endpoints.[1][9][10]

**Zero Marginal Cost**: iMessage uses data connectivity, imposing no per-message charges beyond data plan costs.[11]

**Reliability and Fallback**: If iMessage fails to deliver (recipient offline, no data connectivity, etc.), messages automatically fall back to SMS/MMS with clear visual indication (green bubbles replace blue).[2][11]

This controlled ecosystem creates a *qualitatively* better messaging experience for iPhone-to-iPhone communication, but only when all participants use Apple devices. The moment an Android user joins a conversation, everything degrades to SMS/MMS—by design. This degradation creates the social pressure that drives iPhone adoption, completing the competitive moat.[5][6][1][2][11]

## iCloud Messages Sync: How Cross-Device Synchronization Works

Starting with iOS 11.4 in 2018, Apple introduced "Messages in iCloud," a synchronization system that stores complete message histories in iCloud and keeps them consistent across devices. Understanding this system illuminates both the technical sophistication Apple brings to messaging and the additional complexity it creates for export functionality.[14][13]

### The Pre-Sync Era: Continuity and Its Limitations

Before Messages in iCloud, Apple used "Continuity" to relay messages between devices. This worked by having the iPhone forward incoming messages to registered Macs and iPads through local network connections or iCloud notification relays. Continuity had significant limitations:[13]

- Message history didn't sync; only new messages after device pairing appeared on secondary devices
- Deleting a message on one device didn't delete it on others
- Attachments consumed local storage on every device separately
- Device storage differences created inconsistent message availability across devices[13]

### CloudKit Architecture

Messages in iCloud uses Apple's CloudKit framework, a structured storage system designed for synchronizing user data across devices. CloudKit organizes data into:[46][47][48]

**Containers**: Isolated data spaces for each app. Messages uses its own container separate from Photos, Notes, etc.[47][48][46]

**Databases**: Each container contains three database types:
- **Public Database**: Shared data visible to all app users (not used for Messages)
- **Private Database**: User-scoped data accessible only to authenticated owner devices
- **Shared Database**: "Window" into other users' private databases for collaboration features[48][47]

Messages stores all data in the user's private CloudKit database, ensuring only authenticated devices can access message content.[47][48]

**Records**: Basic storage units, structured as key-value dictionaries with fields containing strings, numbers, dates, locations, references to other records, or assets (large binary data like photos).[48]

**Zones**: Logical subdivisions within databases. Messages creates custom zones supporting atomic multi-record operations—critical for maintaining conversation consistency.[48]

### End-to-End Encryption in iCloud

A key question: how does Messages in iCloud maintain E2EE when storing data in Apple's cloud infrastructure?

The answer involves **CloudKit Service Keys** protected by iCloud Keychain syncing. Here's the technical flow:[49][14]

1. When Messages in iCloud is enabled, the system generates a CloudKit Service Key specific to the Messages container.[14]

2. This Service Key encrypts all message content and attachments before uploading to iCloud.[49][14]

3. The Service Key itself is stored in iCloud Keychain, which uses its own E2EE mechanism. iCloud Keychain requires either:[50][14]
   - A trusted device to approve access (users must approve new devices from existing devices)
   - A recovery contact designated by the user
   - A recovery key stored securely offline[51][50]

4. When a new device signs in with the user's Apple ID, it must pass iCloud Keychain authentication—either via approval from a trusted device or by providing the recovery key/contact verification.[50][14]

5. Only after authentication can the new device obtain the CloudKit Service Key and decrypt message content.[14][50]

This architecture means Apple's servers store encrypted message data but cannot decrypt it without the CloudKit Service Key, which itself is E2EE protected through iCloud Keychain. However, there's a critical caveat: **if iCloud Backup is enabled**, the CloudKit Service Key is included in the backup, which Apple *can* decrypt. Apple can therefore access messages for users who have both Messages in iCloud and iCloud Backup enabled.[21][14]

### Advanced Data Protection: True E2EE for iCloud

To address this limitation, Apple introduced **Advanced Data Protection (ADP)** in December 2022. ADP extends full E2EE to iCloud Backups and several other data categories, including:[52][53][51]

- iCloud Backup
- iCloud Drive  
- Photos
- Notes
- Reminders
- Voice Memos
- Safari Bookmarks
- Wallet passes[53][54][51]

With ADP enabled, Apple genuinely cannot decrypt message backups or cloud-synced data even when served with legal requests. The trade-off: users who lose access to all trusted devices *and* forget their recovery key permanently lose access to their data—Apple cannot help.[54][51][53]

Importantly, ADP is **optional and disabled by default**. Most users never enable it, meaning their messages remain technically accessible to Apple through iCloud Backup decryption keys.[51][53][21]

### Synchronization Mechanism: CKSyncEngine

Messages in iCloud uses Apple's CKSyncEngine framework to manage bidirectional synchronization. The system works through several sophisticated mechanisms:[55][46]

**Change Tracking**: The Messages app tracks all local changes—new messages sent/received, deletions, read status updates, attachment additions. These changes are added to a pending queue managed by CKSyncEngine.[46][55]

**System-Controlled Scheduling**: Unlike traditional sync systems where apps can force immediate synchronization, CloudKit sync is *system-controlled*. iOS decides when to actually upload changes based on:[31][30][46]
- Network connectivity quality and type (Wi-Fi vs. cellular)
- Battery state (Low Power Mode pauses all iCloud sync)[30][31]
- Thermal conditions (overheating pauses sync)[30]
- Background task scheduling priorities[31][46][30]

This means sync may not happen immediately even when changes occur.[31][30]

**Conflict Resolution**: When multiple devices modify the same data simultaneously, CKSyncEngine implements conflict resolution logic to determine the authoritative version. For messages, this typically uses "last write wins" with timestamps determining precedence.[55][46]

**Batched Operations**: Changes upload in batches rather than individually, reducing network overhead and server load. The system automatically handles retry logic for failed uploads.[46][55]

**Push Notifications**: When changes occur on one device, iCloud sends push notifications to other devices prompting them to fetch updates. This enables near-real-time sync when devices are online and connected.[55][46]

### Local Storage: The chat.db Database

On macOS and iOS, messages are stored locally in an SQLite database at `~/Library/Messages/chat.db`. This database uses a complex relational schema with numerous interconnected tables:[56][57][58][59]

**Key Tables**:
- `message`: Contains message text, timestamps, sender/recipient info, read status[57][60][56]
- `chat`: Represents conversations (both individual and group)[56][57]
- `handle`: Stores contact identifiers (phone numbers, email addresses)[57][56]
- `attachment`: Metadata for photos, videos, audio files, documents[56][57]
- `chat_message_join`: Links messages to conversations (many-to-many relationship)[60][57][56]
- `message_attachment_join`: Links messages to attachments (many-to-many)[60][57][56]
- `chat_handle_join`: Links conversations to participants[57][60][56]

Recent macOS versions (Ventura and later) store message text as hex-encoded blobs in the `attributedBody` column rather than plaintext, adding complexity to extraction.[57]

**Attachment Storage**: Large media files are stored separately in the file system, with the `attachment` table containing file paths. When storage fills, iOS offloads older attachments to iCloud, leaving only metadata and low-resolution previews locally. This creates challenges for third-party export tools, which may encounter "Attachment stored in iCloud" placeholders instead of actual files.[17][16][32][56][57]

### Synchronization Behavior and Limitations

Messages in iCloud synchronization exhibits several behaviors relevant to understanding export challenges:

**Deletion Propagation**: When a user deletes a message or conversation on one device, the deletion syncs to all other devices and iCloud. Forensic researchers note that deleted messages are eventually removed from iCloud, typically within several days, though offline devices may temporarily retain deleted content until sync occurs.[61][16][14]

**30-Day Window Theory**: Some users report that attachments remain accessible in iCloud for approximately 30 days after deletion before permanent removal. This appears related to giving offline devices time to process deletion instructions before final cleanup.[16]

**Storage Optimization**: When local device storage fills, iOS automatically deletes older message content and attachments, retaining only recent messages. These are re-downloaded from iCloud on-demand when users scroll back in conversation history.[17]

**Sync Latency**: Under ideal conditions (Wi-Fi, powered device, adequate battery), sync latency ranges from 0.3–0.9 seconds. On cellular networks, this increases to 1.2–2.8 seconds median latency. Sync failures create "Not delivered" warnings even when recipients successfully received messages.[30]

## Why Legal and Regulatory Pressure Hasn't Changed Apple's Position

Given the substantial legal, compliance, and regulatory challenges that iMessage's lack of export creates, why hasn't this pressure forced Apple to implement native export functionality?

### Electronic Discovery Challenges in Litigation

In the United States, Federal Rules of Civil Procedure require parties to preserve and produce electronically stored information (ESI) relevant to reasonably anticipated litigation. This includes text messages and chat communications, regardless of platform.[62][63][64][65]

iMessage creates significant challenges for legal compliance:

**Device-Centric Storage**: Because messages are primarily stored on individual devices rather than centrally managed servers, legal holds require employees to preserve their personal iPhones—often their own property in BYOD (Bring Your Own Device) scenarios.[63][62]

**Easy Deletion**: Users can delete individual messages or entire conversations with a few taps, and if Messages in iCloud is enabled, deletions sync across all devices and eventually remove data from cloud storage. This makes spoliation (destruction of evidence) trivially easy.[61][14]

**Extraction Difficulty**: Courts have repeatedly rejected "technical difficulty" as a defense for failing to produce mobile messages. Companies must implement proactive solutions, but these typically require third-party tools, employee cooperation, or mobile device management (MDM) systems that employees resist.[65][66][67][62][63]

**High-Profile Fines**: A 2023 case study of eDiscovery failures noted that courts have imposed significant sanctions for iMessage-related discovery failures, including adverse inferences (courts instruct juries to assume missing messages would have been unfavorable to the non-producing party), monetary sanctions, and even case dismissals.[67][65]

### Financial Services Regulatory Requirements

The financial services industry faces particularly stringent communications recordkeeping requirements:

**SEC Rule 17a-4**: Requires broker-dealers to retain all business-related communications for specified periods (generally 3-6 years), in a format that is non-rewriteable and non-erasable.[64][68][69]

**FINRA Rule 4511**: Requires member firms to make and preserve books and records, including electronic communications, for regulatory examination.[68][69][64]

**MiFID II (Europe)**: Requires comprehensive recording of telephone conversations and electronic communications relating to transactions.[69][70]

These regulations make no exception for the technical characteristics of specific platforms. If employees conduct business via iMessage, those communications must be captured, retained, and produced upon regulatory request.[64][68][69]

The consequences for non-compliance are severe:

- **$2.7+ billion in SEC/FINRA fines** issued since 2022 for off-channel communication violations, primarily involving WhatsApp and iMessage[66][70][64]
- **Deloitte: $200,000 FINRA fine** after iOS updates disabled their iMessage blocking system, resulting in 676,000 unarchived business communications[70]
- **Bank of America, Morgan Stanley, others**: Individual fines ranging from $125 million to $200 million for similar violations[70][64]

Despite this regulatory pressure, many financial institutions struggle with compliant iMessage archiving. A 2023 survey found that 59% of legal professionals cited mobile messaging—particularly iMessage—as their most difficult eDiscovery challenge.[62]

### GDPR Data Portability Rights

The European Union's General Data Protection Regulation (GDPR), effective May 2018, grants users extensive rights over their personal data, including:

**Article 15 (Right of Access)**: Users can request copies of all personal data an organization holds about them.[71][72]

**Article 20 (Right to Data Portability)**: Users can request data in "structured, commonly used and machine-readable format" and have it transmitted directly to another service provider.[72][73][71]

These provisions theoretically require Apple to provide message export functionality for EU users. However, Apple has successfully argued that iMessage's E2EE architecture means Apple doesn't "process" message content—only metadata like routing information. Since Apple (in their framing) doesn't have access to message content due to E2EE, they claim no obligation to provide export.[74]

This position is controversial. Privacy advocates argue:

1. **Operational Control**: Apple controls the entire iMessage infrastructure and could implement export functionality on-device where decryption keys reside.[75][74]

2. **Proprietary Lock-In**: Requiring an Apple device running Apple software to access one's own message data violates the spirit of data portability.[74][75]

3. **Metadata is Data**: Even if message content is E2EE, Apple processes extensive metadata (sender/recipient identifiers, timestamps, device registrations, push notification routing) that should be exportable.[21][74]

In response to EU Digital Markets Act (DMA) requirements, Apple created the **Account Data Transfer API** in late 2022. This API theoretically enables third-party services to request portability of user data on behalf of users. However, access requires:[76]

- Applying through a formal process with business verification[76]
- Answering detailed questions about intended data use[76]
- Additional review if the applicant has faced relevant regulatory investigations or intends to sell/license user data[76]
- Apple retaining discretion to deny access if it determines "material risk to data protection rights"[76]

Notably, the Account Data Transfer API documentation does not list iMessage content as an available data category, suggesting Apple continues to exclude message content from portability obligations based on the E2EE argument.[76]

### Why Regulatory Pressure Hasn't Worked

Several factors explain why substantial legal and regulatory pressure has not forced Apple to implement native export:

**1. Jurisdictional Fragmentation**: Requirements vary by jurisdiction. GDPR applies in the EU but not the US; SEC/FINRA rules apply to financial services but not other industries; state-level eDiscovery rules differ across US states. Apple can fragment compliance strategies rather than implementing universal export.

**2. Enterprise Solutions Exist**: For regulated industries, third-party compliance solutions like MirrorWeb, Smarsh, Global Relay, and SnippetSentry provide iMessage archiving through MDM systems or on-device capture. These solutions meet regulatory requirements, relieving pressure on Apple to provide native functionality—while generating revenue for compliance vendors.[63][66][69][64]

**3. E2EE as Shield**: Apple's consistent positioning of E2EE as a security *feature* provides both technical justification and positive public perception. Regulators face public backlash when appearing to weaken encryption, giving Apple political cover for design choices that happen to reinforce ecosystem lock-in.[52][21]

**4. User Data vs. Apple Data**: Apple successfully maintains legal distinction between "data users provide to Apple" (which falls under portability obligations) and "data created through Apple's service" (which arguably doesn't). By framing iMessage as a service rather than a data repository, Apple minimizes legal obligations.[74]

**5. Compliance Burden on Users/Employers**: Current legal frameworks place compliance burden on users and employers rather than platform providers. Companies must implement their own capture solutions; individuals must use third-party tools. This diffuses pressure away from Apple.[62][64][70]

## The Export Workarounds: What Users Can Actually Do

While Apple doesn't provide native export, several workarounds exist—each with significant limitations.

### Mac-Based Manual Export

The Mac Messages app includes minimal export functionality:

**Select and Copy**: Users can select individual messages (or multiple messages via "Select All"), copy them to clipboard, and paste into another application. This preserves text but loses formatting, timestamps, sender information, and attachments.[33][77]

**Print to PDF**: Users can select messages and use File > Print, then "Save as PDF". This creates a visual representation but is not machine-readable or searchable in meaningful ways.[74]

**Screenshot**: The simplest but least scalable approach—taking screenshots of conversations. This is obviously impractical for long message histories.[77]

These built-in options are inadequate for any serious archival or legal need.

### Third-Party Commercial Software

Several commercial tools access the local `chat.db` database to enable proper export:

**iMazing** ($45-70 depending on licensing):
- Exports messages to PDF, CSV, Excel, or HTML formats[35][32]
- Includes attachments in exports (when available locally)[32][35]
- Provides conversation filtering and selective export[35][32]
- Works with both live devices and iTunes/iMazing backups[32]
- Limitation: iCloud-offloaded attachments show as "Attachment stored in iCloud" placeholders[32]

**PhoneView** (~$30):
- Mac-only message export utility[78]
- Exports to PDF and text formats[78]
- Includes media extraction capabilities[78]

**TouchCopy** (~$30):
- Similar functionality to PhoneView[79][33]
- Cross-platform (Mac and Windows)[33][79]

**AnyTrans** (pricing varies):
- Comprehensive iOS data management tool[78]
- Messages export as one of many features[78]

These tools work by:
1. Connecting iPhone/iPad to computer via USB
2. Gaining file system access (requires granting "Full Disk Access" permission on Mac)[57]
3. Copying the `chat.db` file and Attachments folder
4. Parsing the SQLite database schema
5. Reconstructing conversations with proper formatting
6. Exporting to user-selected format[56][32][57]

### Open-Source Solutions

For technically proficient users, open-source tools provide free alternatives:

**imessage-exporter** (Rust-based command-line tool):
- Exports conversations to HTML or other formats[34]
- Handles the complex relational database schema automatically[34]
- Named output files by phone number for easy identification[34]
- Requires Rust toolchain installation and command-line comfort[34]
- Installation: `cargo install imessage-exporter`[34]
- Usage: `imessage-exporter -f html -c compatible`[34]

**Direct SQLite Access**:
Advanced users can query `chat.db` directly using SQL tools like TablePlus, SQLite Browser, or command-line `sqlite3`. This requires understanding the database schema and constructing appropriate JOIN queries across multiple tables.[60][56][57]

Recent macOS versions complicate this approach by storing message text as hex-encoded blobs in `attributedBody` rather than plaintext, requiring additional decoding steps.[57]

### Cloud Extraction (Advanced)

For users with Messages in iCloud enabled, a theoretically possible approach involves:

1. Enrolling a new trusted device into the iCloud account[61][13]
2. Allowing Messages in iCloud to fully sync[45][13]
3. Extracting from the local `chat.db` on the newly synced device[56][57]
4. Using third-party tools to download iCloud-stored attachments[32]

Elcomsoft Phone Breaker claims capability to extract E2EE data from iCloud, including Messages in iCloud, but this requires either:
- Lock screen passcode/password from a trusted device[61]
- Access to iCloud Keychain recovery mechanisms[61]
- Advanced forensic techniques beyond typical user capabilities[61]

### Limitations Across All Workarounds

Every export workaround shares common limitations:

**Attachment Availability**: Messages in iCloud with storage optimization means many attachments exist only in iCloud, not locally. Third-party tools can't access these without additional steps.[16][17][32]

**Deleted Message Recovery**: Once messages are deleted and sync completes, they're removed from iCloud within days. No export tool can recover them afterward.[14][16]

**Encryption Dependencies**: All tools depend on local device access where private keys reside. Remote export from iCloud alone is impossible due to E2EE architecture.[22][24]

**Format Preservation**: Reactions, message effects, Memoji animations, and other iMessage-specific features often don't translate to export formats.[34]

**Group Chat Complexity**: Group conversation threading and participant changes over time challenge many export tools' ability to properly reconstruct conversation context.[60]

**Ongoing Effort**: Unlike native export, these approaches require per-device, per-backup manual effort—they don't provide continuous automated archiving.[64][70]

## Conclusion: The Strategic Rationality of Inaction

Apple's refusal to implement native iMessage export functionality is not an engineering constraint, an oversight, or a simple profit-maximization calculation. It represents a sophisticated, multi-dimensional strategic decision that balances:

**Competitive Positioning**: iMessage serves as one of Apple's most powerful retention mechanisms, creating social pressure—especially among younger users—that actively drives iPhone adoption and prevents switching to competing platforms. Native export would weaken this competitive moat by reducing switching costs.[1][2][5]

**Services Revenue**: The lack of export encourages iCloud storage purchases as message histories and attachments accumulate. It also reinforces dependence on Apple's device ecosystem for accessing personal communications history, supporting hardware upgrade cycles.[8][17][16]

**Privacy Marketing**: Apple successfully positions iMessage's E2EE as a security *feature* deserving premium value. Introducing export functionality could be framed by critics as weakening security, undermining Apple's carefully cultivated privacy brand differentiation.[52][21]

**Legal Complexity**: Native export would increase Apple's responsibilities under data protection, discovery, and compliance frameworks globally. The current architecture places burden on users and employers to implement their own solutions, limiting Apple's legal exposure.[62][64][74]

**Technical Credibility**: The genuine technical complexity of E2EE, multi-device synchronization, and attachment management provides plausible justification for the absence of export, even though third-party developers have solved these challenges with far fewer resources.[35][32][34]

From Apple's perspective, the status quo optimizes across these considerations. The company faces manageable regulatory pressure that hasn't generated existential threats; suffers minimal reputational harm since most users don't prioritize export functionality until specific needs arise (legal discovery, device switching); and maintains powerful ecosystem lock-in effects that drive Services revenue growth and hardware loyalty.

For users, the lack of native export represents a subtle but significant limitation on data autonomy—one that becomes apparent only when trying to leave Apple's ecosystem, preserve conversations for legal/professional purposes, or simply maintain control over personal digital archives accumulated over years or decades of daily communication. Third-party workarounds exist but impose technical complexity, ongoing maintenance burden, and imperfect functionality that few users successfully navigate.

Ultimately, Apple will implement native iMessage export only when external pressure—whether regulatory, competitive, or reputational—exceeds the substantial strategic value the company derives from maintaining the current architecture. Given the effectiveness of Apple's ecosystem lock-in strategy and the company's $3+ trillion market capitalization partly built on Services revenue growth, that threshold appears distant. The walls of Apple's walled garden remain firmly intact, with iMessage serving as one of the most effective gates preventing exit.

Sources
[1] Network Effect and Apple iMessage - Cornell blogs https://blogs.cornell.edu/info2040/2018/11/28/network-effect-and-apple-imessage/
[2] Why Apple's iMessage Is Winning: Teens Dread the Green Text ... https://www.wsj.com/tech/why-apples-imessage-is-winning-teens-dread-the-green-text-bubble-11641618009
[3] Apple's 'Walled Garden' Ensures Profit even if You're not Paying them https://www.ttuhub.net/2024/02/apples-walled-garden-ensures-profit-even-if-youre-not-paying-them/
[4] Case Study: Apple's Ecosystem Strategy - Building Loyalty and ... https://cdotimes.com/2024/11/21/case-study-apples-ecosystem-strategy-building-loyalty-and-revenue-through-integration-and-innovation/
[5] Google's Done Playing Nice: The Real Truth Behind the Bubble Wars https://android.gadgethacks.com/news/googles-done-playing-nice-the-real-truth-behind-the-bubble-wars/
[6] Apple's Lock-in - TechConstant https://www.techconstant.com/apples-lock-in/
[7] Apple's AI Strategy: A Structural Advantage Endures - AInvest https://www.ainvest.com/news/apple-ai-strategy-structural-advantage-endures-2602/
[8] Apple Subscription Revenue 2025: Growth, Margins & Strategy https://www.hubifi.com/blog/apple-subscription-revenue-breakdown
[9] RCS vs iMessage: Security, Features, and Compliance - LeapXpert https://www.leapxpert.com/rcs-vs-imessage/
[10] RCS vs iMessage: A Detailed Comparison to Help You Choose https://clerk.chat/blog/rcs-vs-imessage/
[11] Green Bubbles: How Apple Quietly Gets iPhone Users To Hate ... https://www.techdirt.com/2015/02/12/green-bubbles-how-apple-quietly-gets-iphone-users-to-hate-android-users/
[12] AAPL Economic Moat - Apple Inc - Alpha Spread https://www.alphaspread.com/security/nasdaq/aapl/qualitative/block/economic-moat
[13] How to Obtain iMessages from iCloud - ElcomSoft blog https://blog.elcomsoft.com/2018/06/how-to-obtain-imessages-from-icloud/
[14] iMessage Security, Encryption and Attachments https://blog.elcomsoft.com/2018/11/imessage-security-encryption-and-attachments/
[15] What's Apple's Business Model for Apple Music? - Reprtoir https://www.reprtoir.com/blog/apple-music-business-model
[16] How do I stop iMessage from using up so much iCloud storage ... https://www.reddit.com/r/ios/comments/174s637/how_do_i_stop_imessage_from_using_up_so_much/
[17] If 'Messages' Consumes Too Much iPhone or iCloud Storage, Don't ... https://ios.gadgethacks.com/how-to/if-messages-consumes-too-much-iphone-icloud-storage-dont-delete-your-conversations-just-yet-0384614/
[18] iMessage makeover on equal footing with Signal https://arstechnica.com/security/2024/02/imessage-gets-a-major-makeover-that-puts-it-on-equal-footing-with-signal/
[19] What is iMessage: Features, Benefits & the Tech Behind It https://jatheon.com/blog/what-is-imessage/
[20] iMessage with PQ3: The new state of the art in quantum-secure ... https://security.apple.com/blog/imessage-pq3/
[21] iMessage App Review 2025: Privacy, Pros and Cons, Personal Data https://www.mozillafoundation.org/en/nothing-personal/imessage-privacy-review/
[22] How secure is iMessage? - Comparitech https://www.comparitech.com/blog/vpn-privacy/how-secure-is-imessage/
[23] How iMessage distributes security to block “phantom devices” https://securosis.com/blog/how-imessage-distributes-security-to-block-phantom-devices-2/
[24] Advancing iMessage security: iMessage Contact Key Verification https://security.apple.com/blog/imessage-contact-key-verification/
[25] iMessage security overview - Apple Support https://support.apple.com/guide/security/imessage-security-overview-secd9764312f/web
[26] Apple Improves iMessage Security With Contact Key Verification https://www.securityweek.com/apple-improves-imessage-security-with-contact-key-verification/
[27] How iMessage sends and receives messages securely https://support.apple.com/guide/security/how-imessage-sends-and-receives-messages-sec70e68c949/web
[28] Apple Beefs Up iMessage With Quantum-Resistant Encryption https://www.darkreading.com/endpoint-security/apple-beefs-up-imessage-with-quantum-resistant-encryption
[29] Apple to protect iMessage chats from quantum attacks - The Register https://www.theregister.com/2024/02/21/apple_postquantum_security/
[30] How to See Which Messages Apple Is Storing in iCloud - LifeTips https://lifetips.alibaba.com/tech-efficiency/how-to-see-which-messages-apple-is-storing-in-icloud
[31] iOS iCloud Drive Synchronization Deep Dive - Carlo Zottmann https://zottmann.org/2025/09/08/ios-icloud-drive-synchronization-deep.html
[32] Export iPhone Messages (SMS, RCS, iMessage) to your computer in ... https://imazing.com/guides/how-to-export-iphone-text-messages-sms-and-imessages-to-your-computer-as-pdf-excel-csv-or-rsmf
[33] Export iMessage conversation - Apple Support Communities https://discussions.apple.com/thread/255416051
[34] How to export whole iMessage conversation lasting years to pdf on ... https://www.reddit.com/r/MacOS/comments/14jy8h7/how_to_export_whole_imessage_conversation_lasting/
[35] iMazing alternatives 2026: AnyTrans vs iMazing — which one wins? https://setapp.com/app-reviews/anytrans-vs-imazing
[36] I wanted to be able to export/backup iMessage conversations with ... https://www.reddit.com/r/apple/comments/10cp8dh/i_wanted_to_be_able_to_exportbackup_imessage/
[37] RCS vs SMS Message: The Definitive Difference Between RCS and ... https://curogram.com/blog/rcs-vs-sms
[38] SMS Limits and How to Optimize Your Campaigns - LINK Mobility https://www.linkmobility.com/blog/sms-limits-and-how-to-optimize-your-campaigns
[39] How long can a message be? | Twilio https://www.twilio.com/docs/glossary/what-sms-character-limit
[40] SMS character limits - AWS End User Messaging SMS https://docs.aws.amazon.com/sms-voice/latest/userguide/sms-limitations-character.html
[41] Messaging Character Limits - Signalmash https://www.signalmash.com/what-sms-character-limit
[42] What is RCS and how is it different from SMS and iMessage? https://www.engadget.com/what-is-rcs-and-how-is-it-different-from-sms-and-imessage-202334057.html
[43] RCS vs iMessage: Know the Difference [2025] - Sinch https://sinch.com/blog/rcs-vs-imessage/
[44] How to Sync Your Text Messages across All Your Apple Devices https://www.linkedin.com/pulse/how-sync-your-text-messages-across-all-apple-ddaec
[45] How to Sync Your Text Messages across All Your Apple Devices https://www.mbsdirect.com/mbs-blog/article-how-to-sync-your-text-messages-across-all-your-apple-devices
[46] Sync to iCloud with CKSyncEngine - WWDC23 - Videos https://developer.apple.com/la/videos/play/wwdc2023/10188/
[47] What's new in CloudKit - WWDC21 - Vidéos - Apple Developer https://developer.apple.com/fr/videos/play/wwdc2021/10086/
[48] [PDF] CloudKit: Structured Storage for Mobile Applications https://www.vldb.org/pvldb/vol11/p540-shraer.pdf
[49] Why Turn on End-to-End Encryption for iMessage, iCloud, iPhone ... https://modeone.io/blogs/why-turn-on-end-to-end-encryption-for-imessage-icloud-iphone-backups-in-ios-16-2/
[50] How is Apple keeping end-to-end encryption for Messages in iCloud? https://www.reddit.com/r/apple/comments/8n17ns/how_is_apple_keeping_endtoend_encryption_for/
[51] How Apple's Advanced Data Protection Works, and How to Enable It ... https://www.wired.com/story/how-apple-advanced-data-protection-works-and-how-to-turn-it-on/
[52] Apple advances user security with powerful new data protections https://www.apple.com/newsroom/2022/12/apple-advances-user-security-with-powerful-new-data-protections/
[53] iCloud and Advanced Data Protection: total security? - negg Blog https://negg.blog/en/icloud-and-advanced-data-protection-total-security/
[54] How to turn on Advanced Data Protection for iCloud - Apple Support https://support.apple.com/en-us/108756
[55] WWDC23: Sync to iCloud with CKSyncEngine | Apple - YouTube https://www.youtube.com/watch?v=BUFaXlNYokA
[56] Fixing iMessage search with DuckDB - areca data https://www.arecadata.com/analyzing-imessage-data-with-duckdb/
[57] Searching Your iMessage Database (Chat.db file) with SQL https://spin.atomicobject.com/search-imessage-sql/
[58] Restore OS X iMessages History from chat.db - Stack Overflow https://stackoverflow.com/questions/27142623/restore-os-x-imessages-history-from-chat-db
[59] Viewing iMessage History on a Computer — Feifan Zhou's Blog https://feifan.blog/posts/viewing-imessage-history-on-a-computer
[60] Cracking The Code Of iOS Messages: A Guide To Storage And ... https://www.forensicfocus.com/webinars/cracking-the-code-of-ios-messages-a-guide-to-storage-and-analysis-techniques-for-forensic-examiners/
[61] Dude, Where Are My Messages? - ElcomSoft blog https://blog.elcomsoft.com/2022/02/dude-where-are-my-messages/
[62] iMessage Discovery and the Challenge of Litigation Holds https://www.deepview.com/the-legal-blindspot-imessage-discovery-and-the-challenge-of-litigation-holds/
[63] The Hidden Compliance Risks Lurking in Your iMessages https://www.corporatecomplianceinsights.com/hidden-compliance-risks-lurking-in-your-imessages/
[64] iMessage Compliance for Regulated Industries - SnippetSentry https://snippetsentry.com/imessage-compliance-for-regulated-industries/
[65] Electronic Discovery Challenges in Federal Criminal Cases: Legal ... https://leppardlaw.com/federal/motions/electronic-discovery-challenges-in-federal-criminal-cases-legal-approaches/
[66] iMessage Is a Compliance Risk, and Everyone's Finally ... https://www.mirrorweb.com/blog/imessage-is-a-compliance-risk-and-everyones-finally-talking-about-it
[67] [PDF] Technical Challenges Are No Excuse For Discovery Failures https://www.skadden.com/-/media/files/publications/2023/03/technical_challenges_are_no_excuse_for_discovery_failures.pdf?rev=3370df8ef5884af5a5d34e737854a2b8
[68] iMessage Recordkeeping - LeapXpert https://www.leapxpert.com/glossary_term/imessage-recordkeeping/
[69] iMessage Compliance Recording | Seamless FCA Solutions - Kerv https://kerv.com/what-we-do/communications-compliance/imessage-compliance-recording/
[70] iMessage Compliance: Challenges, Risks, and Solutions - Jatheon https://jatheon.com/blog/imessage-compliance/
[71] Art. 20 GDPR – Right to data portability https://gdpr-info.eu/art-20-gdpr/
[72] GDPR Violation – No Export Option for ChatGPT Team Workspace ... https://community.openai.com/t/urgent-gdpr-violation-no-export-option-for-chatgpt-team-workspace-data/1090657
[73] [PDF] An Empirical Analysis on the Effectiveness of GDPR Art. 20 https://petsymposium.org/popets/2021/popets-2021-0051.pdf
[74] Does GDPR mandate that companies, such as Apple, allow ... - Reddit https://www.reddit.com/r/gdpr/comments/10jq91t/does_gdpr_mandate_that_companies_such_as_apple/
[75] Need ability to export imessages - Apple Support Communities https://discussions.apple.com/thread/252368393
[76] Requesting portability of data for users in the European Union https://developer.apple.com/support/account-data-transfer-api-eu/
[77] Download Text Messages from iPhone to PDF/CSV (2026 Guide) https://www.gbyte.com/blog/download-text-messages-from-iphone
[78] A Comprehensive Guide to Storing Text Messages on Your iPhone http://oreateai.com/blog/a-comprehensive-guide-to-storing-text-messages-on-your-iphone/59c1e05ecb5c6be6e842f43198d03b9c
[79] Exporting text messages from iphone to em… - Apple Community https://discussions.apple.com/thread/255489626
[80] How to Save Text Messages from iPhone (3 Easy Ways ... - YouTube https://www.youtube.com/watch?v=ycOCqcfo288
[81] [PDF] iMessage's End-to-End Encryption - How It Got Hacked https://www.cs.tufts.edu/comp/116/archive/fall2016/xshi.pdf
[82] How can privacy be maintained with upcoming iCloud messages ... https://www.reddit.com/r/apple/comments/8cgf4j/how_can_privacy_be_maintained_with_upcoming/
[83] Synchronizing Messages Across Devices - TidBITS Talk https://talk.tidbits.com/t/synchronizing-messages-across-devices/26533
[84] Does iCloud Save Text Messages? The Facts and Fictions https://www.gbyte.com/blog/does-icloud-save-text-messages
[85] iOS 26.1 - SMS read/unread status not syncing across apple devices https://discussions.apple.com/thread/256195282
[86] iPhone iMessage Database File - Apple Support Communities https://discussions.apple.com/thread/255549033
[87] iPhone messages not syncing from iCloud? - Facebook https://www.facebook.com/groups/328748646935424/posts/710417395435212/
[88] What are weak points of Apple's iMessage? : r/privacy - Reddit https://www.reddit.com/r/privacy/comments/1gln5ic/what_are_weak_points_of_apples_imessage/
[89] [PDF] GDPR Data Portability: The Forgotten Right https://cellar-c2.services.clever-cloud.com/alias-code-is-law-assets/static/report/gdpr_data_portability_the_forgotten_right_report_full.pdf
[90] GDPR introduces the new personal data portability right - Weople https://weople.space/en/faq
[91] Apple Previews New iMessage and Apple ID Security Features ... https://forums.macrumors.com/threads/apple-previews-new-imessage-and-apple-id-security-features-coming-in-2023.2372827/
[92] Comments on the interplay of the EU DMA and the GDPR https://eutechreg.com/p/comments-on-the-interplay-of-the
[93] Apple's New iMessage, Signal, & Post-Quantum Crypto | CSA https://cloudsecurityalliance.org/blog/2024/05/17/apple-s-new-imessage-signal-and-post-quantum-cryptography
[94] Does Apple iMessage Use End-to-End Encryption? - YouTube https://www.youtube.com/watch?v=QoWn2Zw_R8w
[95] iMessage Privacy - Quarkslab's blog https://blog.quarkslab.com/imessage-privacy.html
[96] iMessage Encryption Flaw Found and Fixed - Schneier on Security - https://www.schneier.com/blog/archives/2016/03/imessage_encryp.html
[97] Set up iCloud for Messages on all your devices - Apple Support https://support.apple.com/guide/icloud/set-up-messages-mm0de0d4528d/icloud
[98] Sharing CloudKit Data with Other iCloud Users - Apple Developer https://developer.apple.com/documentation/CloudKit/sharing-cloudkit-data-with-other-icloud-users
[99] Messages in iCloud - Storage and How It Works - YouTube https://www.youtube.com/watch?v=gqWHfbFonNM
[100] How to Sync User Data Across iOS Devices with CloudKit | Toptal® https://www.toptal.com/developers/ios/sync-data-across-devices-with-cloudkit
[101] How iCloud Sync Works on iPhone, iPad, and Mac - YouTube https://www.youtube.com/watch?v=ARyhXMvu99A
[102] iCloud encryption https://support.apple.com/guide/security/icloud-encryption-sec3cac31735/web
[103] The walls of Apple's garden are tumbling down | The Verge https://www.theverge.com/24141929/apple-iphone-imessage-antitrust-dma-lock-in
[104] Google declares the green vs blue bubbles debate 'silly and tired ... https://www.reddit.com/r/apple/comments/1mvsmsy/google_declares_the_green_vs_blue_bubbles_debate/
[105] What do you guys consider having the 'Apple Ecosystem' to mean? https://www.reddit.com/r/apple/comments/1882lwg/what_do_you_guys_consider_having_the_apple/
[106] SMS character limit & how message length impacts costs - Infobip https://www.infobip.com/blog/sms-character-limit
[107] Advanced Data Protection Apple iCloud - YouTube https://www.youtube.com/watch?v=Xjs0OVb7ECE
[108] Apple posts record quarterly revenue driven by 'staggering' iPhone ... https://siliconangle.com/2026/01/29/apple-posts-record-breaking-quarterly-revenue-driven-staggering-iphone-17-demand/
[109] iCloud Advanced Data Protection is not truly end-to-end encrypted https://www.reddit.com/r/privacy/comments/1o6kry4/icloud_advanced_data_protection_is_not_truly/
[110] Overcoming 5 eDiscovery Challenges - TransPerfect Legal Solutions https://www.transperfectlegal.com/blog/five-ediscovery-data-source-challenges-and-how-overcome-them
[111] Legal - Apple Messages for Business & Privacy https://www.apple.com/legal/privacy/data/en/messages-for-business/
[112] How should I setup my database schema for a messaging system ... https://stackoverflow.com/questions/1890481/how-should-i-setup-my-database-schema-for-a-messaging-system-complete-with-attac
[113] How to Fix “iMessage Taking Up Too Much Space” on your iPhone https://www.youtube.com/watch?v=1uCUiAlsxok
[114] What is the relation between user_messages and Messages tables ... https://www.reddit.com/r/dataengineering/comments/1e2y81l/what_is_the_relation_between_user_messages_and/
[115] Private data sharing using CloudKit - Stack Overflow https://stackoverflow.com/questions/26579222/private-data-sharing-using-cloudkit
[116] Offload Mac Messages attachments to iCloud - Apple Community https://discussions.apple.com/thread/256223471
[117] Designing and Creating a CloudKit Database - Apple Developer https://developer.apple.com/documentation/cloudkit/designing-and-creating-a-cloudkit-database
[118] Why are iPhone messages taking up so much storage space? https://www.facebook.com/groups/it.humor.and.memes/posts/29960351323563933/
[119] CloudKit.Database | Apple Developer Documentation https://developer.apple.com/documentation/cloudkitjs/cloudkit.database
