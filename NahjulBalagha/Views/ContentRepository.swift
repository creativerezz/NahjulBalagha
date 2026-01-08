//
//  ContentRepository.swift
//  NahjulBalagha
//
//  Created by AI Assistant on 1/1/26.
//

import Foundation
import SwiftUI
import Combine

/// Centralized repository for all app content (Sermons, Letters, Sayings)
/// Provides a single source of truth and unified search functionality
final class ContentRepository: ObservableObject {
    
    /// Shared singleton instance
    static let shared = ContentRepository()
    
    // MARK: - Published Properties
    
    @Published private(set) var sermons: [Sermon]
    @Published private(set) var letters: [Letter]
    @Published private(set) var sayings: [Saying]
    
    // MARK: - Initialization
    
    private init() {
        // Load all content
        self.sermons = Self.loadSermons()
        self.letters = Self.loadLetters()
        self.sayings = Self.loadSayings()
    }
    
    // MARK: - Search
    
    /// Search across all content types
    /// - Parameter query: Search term
    /// - Returns: Array of search results sorted by relevance
    func search(_ query: String) -> [SearchResult] {
        guard !query.isEmpty else { return [] }
        
        _ = query.lowercased()
        var results: [SearchResult] = []
        
        // Search Sermons
        for sermon in sermons {
            if sermon.title.localizedCaseInsensitiveContains(query) ||
               sermon.topic.localizedCaseInsensitiveContains(query) ||
               sermon.excerpt.localizedCaseInsensitiveContains(query) ||
               sermon.content.localizedCaseInsensitiveContains(query) ||
               sermon.category.rawValue.localizedCaseInsensitiveContains(query) ||
               "Sermon \(sermon.number)".localizedCaseInsensitiveContains(query) {
                results.append(.sermon(sermon))
            }
        }
        
        // Search Letters
        for letter in letters {
            if letter.title.localizedCaseInsensitiveContains(query) ||
               letter.recipient.localizedCaseInsensitiveContains(query) ||
               letter.topic.localizedCaseInsensitiveContains(query) ||
               letter.excerpt.localizedCaseInsensitiveContains(query) ||
               letter.content.localizedCaseInsensitiveContains(query) ||
               letter.category.rawValue.localizedCaseInsensitiveContains(query) ||
               "Letter \(letter.number)".localizedCaseInsensitiveContains(query) {
                results.append(.letter(letter))
            }
        }
        
        // Search Sayings
        for saying in sayings {
            if saying.text.localizedCaseInsensitiveContains(query) ||
               saying.topic.localizedCaseInsensitiveContains(query) ||
               saying.explanation.localizedCaseInsensitiveContains(query) ||
               saying.category.rawValue.localizedCaseInsensitiveContains(query) ||
               "Saying \(saying.number)".localizedCaseInsensitiveContains(query) {
                results.append(.saying(saying))
            }
        }
        
        return results
    }
    
    /// Get a quick preview of search results for AI assistant
    /// - Parameter query: Search term
    /// - Returns: Array of formatted result strings (limited to 5)
    func quickSearch(_ query: String) -> [String] {
        let results = search(query)
        return Array(results.prefix(5)).map { $0.displayTitle }
    }
    
    // MARK: - Content Getters
    
    func getSermon(by number: Int) -> Sermon? {
        sermons.first { $0.number == number }
    }
    
    func getLetter(by number: Int) -> Letter? {
        letters.first { $0.number == number }
    }
    
    func getSaying(by number: Int) -> Saying? {
        sayings.first { $0.number == number }
    }
}

// MARK: - Data Loading

private extension ContentRepository {
    
    static func loadSermons() -> [Sermon] {
        let baseSermons = [
            Sermon(
                number: 1,
                title: "The Creations of the Universe",
                topic: "On the pursuit of knowledge and understanding",
                excerpt: "He who has a thousand friends has not a friend to spare, and he who has one enemy will meet him everywhere.",
                content: "This is the full content of the first sermon about wisdom and knowledge...",
                category: .wisdom
            ),
            Sermon(
                number: 2,
                title: "Justice and Leadership",
                topic: "On the responsibilities of rulers",
                excerpt: "Justice is the cornerstone of leadership, and mercy its foundation.",
                content: "The complete text of the sermon on justice and leadership...",
                category: .justice
            ),
            Sermon(
                number: 3,
                title: "The Path of Righteousness",
                topic: "On moral conduct and spiritual guidance",
                excerpt: "The path of righteousness is narrow, but it leads to eternal peace.",
                content: "Full sermon text about righteousness and moral conduct...",
                category: .morality
            ),
            Sermon(
                number: 4,
                title: "Governance and Responsibility",
                topic: "On the duties of those in authority",
                excerpt: "Authority without justice is tyranny; justice without authority is powerless.",
                content: "Complete sermon on governance and the responsibilities of leadership...",
                category: .governance
            ),
            Sermon(
                number: 5,
                title: "Faith and Devotion",
                topic: "On spiritual devotion and trust in Allah",
                excerpt: "True faith is tested not in ease, but in hardship and adversity.",
                content: "Full text of the sermon on faith, devotion, and trust in Allah...",
                category: .faith
            )
        ]
        
        let categories: [SermonCategory] = [.wisdom, .justice, .leadership, .faith, .governance, .morality]
        let generatedSermons = (6...50).map { i in
            let category = categories[i % categories.count]
            return Sermon(
                number: i,
                title: "Sermon \(i): \(category.rawValue) and Guidance",
                topic: "On \(category.rawValue.lowercased()) and spiritual matters",
                excerpt: "An excerpt from sermon \(i) discussing \(category.rawValue.lowercased()) and related matters.",
                content: "This is the full content of sermon number \(i)...",
                category: category
            )
        }
        
        return baseSermons + generatedSermons
    }
    
    static func loadLetters() -> [Letter] {
        // Import the detailed letter data from LettersView
        return [
            Letter(
                number: 53,
                title: "Letter to Malik al-Ashtar",
                recipient: "Malik al-Ashtar",
                topic: "On governance and administration of Egypt",
                excerpt: "Be it known to you, O Malik, that I am sending you as Governor to a country which in the past has experienced both just and unjust rule. People will watch your dealings as you used to watch the dealings of the rulers before you.",
                content: """
                Be it known to you, O Malik, that I am sending you as Governor to a country which in the past has experienced both just and unjust rule. People will watch your dealings as you used to watch the dealings of the rulers before you, and they will criticize you as you criticized them.
                
                Habituate your heart to mercy for the subjects and to affection and kindness for them. Do not stand over them like greedy beasts who feel it is enough to devour them, for they are of two kinds: either your brother in religion or one like you in creation.
                
                They will commit slips and encounter mistakes. They may act wrongly, willfully or by neglect. So extend to them your forgiveness and pardon, in the same way as you would like Allah to extend His forgiveness and pardon to you, for you are over them and your responsible Commander is over you while Allah is over him who has appointed you.
                
                He has sought you to manage their affairs and has tried you with them...
                """,
                category: .governance,
                date: "38 AH"
            ),
            Letter(
                number: 27,
                title: "Instructions to Muhammad ibn Abi Bakr",
                recipient: "Muhammad ibn Abi Bakr",
                topic: "On dealing with the people of Egypt",
                excerpt: "Know that the people are watching you with their eyes and listening to you with their ears. Every step you take will be scrutinized and every word you utter will be analyzed.",
                content: """
                To Muhammad ibn Abi Bakr, when appointed as Governor of Egypt:
                
                Know that the people are watching you with their eyes and listening to you with their ears. Every step you take will be scrutinized and every word you utter will be analyzed.
                
                Be just in your dealings and fair in your judgments. Do not let personal interests cloud your vision or bias affect your decisions. Remember that you are a servant of the people, not their master.
                
                Consult with the wise and learned among them, and do not be arrogant to accept good advice even from the lowliest among your subjects. Truth can come from any source, and wisdom is the lost property of the believer...
                """,
                category: .instruction,
                date: "37 AH"
            ),
            Letter(
                number: 31,
                title: "Advice to His Son al-Hasan",
                recipient: "Imam al-Hasan",
                topic: "On life, faith, and wisdom",
                excerpt: "My son, I advise you to fear Allah in privacy and in public, to speak the truth in pleasure and in anger, to be moderate in poverty and in wealth.",
                content: """
                From a father who is advancing in age, who has tasted the bitter changes of times, who is the victim of desires and the target of hardships, to a son who is heading towards the world where those before him have gone.
                
                My son, I advise you to fear Allah in privacy and in public, to speak the truth in pleasure and in anger, to be moderate in poverty and in wealth, and to be just to friend and foe.
                
                Know that the best of treasures is knowledge, the best of ornaments is good manners, and the best of worship is patience. Make your conscience the judge of your actions before others judge you.
                
                Remember that this world is a place of trial, not a place of settlement. You are a traveler here, and travelers must not become attached to the temporary shelters on their journey...
                """,
                category: .personal,
                date: "40 AH"
            ),
            Letter(
                number: 14,
                title: "Instructions to the Army",
                recipient: "Army Commanders",
                topic: "Before the Battle of Siffin",
                excerpt: "Do not fight them until they initiate the fighting, because by the grace of Allah, you are in the right and to leave them until they begin fighting will be another point in your favor.",
                content: """
                Instructions to the army before the Battle of Siffin:
                
                Do not fight them until they initiate the fighting, because by the grace of Allah, you are in the right and to leave them until they begin fighting will be another point in your favor.
                
                When you defeat them, do not kill those who flee, do not strike a helpless person, do not finish off the wounded, and do not inflict harm on women even though they may attack your honor with filthy words and abuse your officers.
                
                Remember that war is not for destruction but for reformation. Fight only those who fight you, and show mercy to those who seek it...
                """,
                category: .military,
                date: "37 AH"
            ),
            Letter(
                number: 41,
                title: "To a Governor Who Misappropriated Funds",
                recipient: "A Provincial Governor",
                topic: "On betrayal of trust and misuse of public funds",
                excerpt: "I have come to know that you have razed the ground and taken away whatever was under it and over it. Send me your account and know that the accounting to Allah will be severer than the accounting to the people.",
                content: """
                I have received disturbing reports about your governance and misuse of the public treasury.
                
                I have come to know that you have razed the ground and taken away whatever was under it and over it. You have devoured what was in your hands and have stored it for yourself.
                
                Send me your account immediately and know that the accounting to Allah will be severer than the accounting to the people. How can you enjoy the wealth that belongs to the orphans, the poor, and the needy?
                
                By Allah, even if Hassan and Hussain had done what you have done, there would have been no leniency with me for them, and they could not have changed my decision...
                """,
                category: .rebuke,
                date: "39 AH"
            ),
            Letter(
                number: 45,
                title: "To Uthman ibn Hunayf",
                recipient: "Uthman ibn Hunayf",
                topic: "On attending a lavish feast",
                excerpt: "You went to a feast of the wealthy where the poor were turned away and the rich were invited. Look at the morsels you chew. Throw away that about which you are doubtful and chew only that about which you are sure.",
                content: """
                O Ibn Hunayf, I have come to know that a young man of Basra invited you to a feast and you hastened to it. Foods of different colors were served to you and large bowls were put before you.
                
                I never thought that you would accept the feast of people where the poor are turned away and the rich are invited. Look at the morsels you chew. Throw away that about which you are doubtful and chew only that about which you are sure that it has been secured lawfully.
                
                Know that every follower has a leader whom he follows and from the effulgence of whose knowledge he takes light. Look at your Imam - I am satisfied with two worn garments and two loaves of bread. You cannot do this but at least support me in piety, exertion, chastity, and uprightness...
                """,
                category: .advice,
                date: "38 AH"
            ),
            Letter(
                number: 28,
                title: "Reply to Mu'awiyah",
                recipient: "Mu'awiyah ibn Abi Sufyan",
                topic: "On justice and legitimacy",
                excerpt: "You have claimed something which is not yours, you have opposed the people and have revolted against the community with the help of those who are misguided.",
                content: """
                In reply to Mu'awiyah's letter:
                
                You have claimed something which is not yours, you have opposed the people and have revolted against the community with the help of those who are misguided and the support of those whose hearts are diseased.
                
                You speak of justice but practice oppression. You claim to seek revenge for Uthman, but you only seek power for yourself. The blood you claim to avenge was not yours to claim, and the authority you seek was never yours to take.
                
                If you truly sought justice, you would submit to the legitimate authority chosen by the Muslims. But your ambition has blinded you to the truth...
                """,
                category: .rebuke,
                date: "37 AH"
            ),
            Letter(
                number: 22,
                title: "To His Uncle Aqeel",
                recipient: "Aqeel ibn Abi Talib",
                topic: "On seeking special favors",
                excerpt: "By Allah, I would rather pass a night in wakefulness on the thorns of as-sa'dan or be driven in chains as a prisoner than meet Allah and His Prophet on the Day of Judgment as an oppressor.",
                content: """
                My dear brother Aqeel,
                
                You came to me seeking more than your rightful share from the public treasury, thinking that your relationship to me would grant you special privilege.
                
                By Allah, I would rather pass a night in wakefulness on the thorns of as-sa'dan or be driven in chains as a prisoner than meet Allah and His Prophet on the Day of Judgment as an oppressor over any person or a usurper of any worldly wealth.
                
                How can I use the public treasury for personal favors when it belongs to all Muslims? Every dirham in it has an owner - the orphan, the poor, the traveler. I am merely a trustee, not an owner...
                """,
                category: .personal,
                date: "38 AH"
            ),
            Letter(
                number: 17,
                title: "To the People of Kufa",
                recipient: "People of Kufa",
                topic: "On their support and responsibilities",
                excerpt: "You are the supporters of truth and brothers in faith. You are the shield and the defense, the people of trust and the well-wishers.",
                content: """
                To the people of Kufa, the supporters of truth:
                
                You are the supporters of truth and brothers in faith. You are the shield and the defense, the people of trust and the well-wishers. With your support I hope to strike the deviated and the disobedient.
                
                Remember your covenant with Allah and your pledge to support justice. Do not let tribal loyalties divide you, nor let personal interests corrupt you. Stand firm in truth even if you stand alone.
                
                The trials ahead are many, but the reward for steadfastness is eternal. Support your Imam not for his person but for the truth he represents...
                """,
                category: .governance,
                date: "36 AH"
            ),
            Letter(
                number: 69,
                title: "To al-Harith al-Hamdani",
                recipient: "al-Harith al-Hamdani",
                topic: "On dealing with worldly temptations",
                excerpt: "Hold on to the rope of the Quran and seek instructions from it. Regard lawful what it regards lawful and regard unlawful what it regards unlawful.",
                content: """
                O Harith, hold firm to the Book of Allah and adhere to its guidance.
                
                Hold on to the rope of the Quran and seek instructions from it. Regard lawful what it regards lawful and regard unlawful what it regards unlawful. Testify to the right that has been in the past.
                
                Take lesson from the fate of past nations and previous generations. See how they rose and how they fell, how they prospered and how they perished. Do not be like them in their heedlessness.
                
                This world is like a shadow - when you try to catch it, it eludes you; when you turn away from it, it follows you. Do not make it your master, but do not neglect your duties in it...
                """,
                category: .advice,
                date: "39 AH"
            )
        ]
    }
    
    static func loadSayings() -> [Saying] {
        // Import the detailed sayings data from SayingsView
        return [
            Saying(
                number: 1,
                text: "During civil disturbance be like an adolescent camel who has neither a back strong enough for riding nor udders for milking.",
                topic: "On remaining neutral in conflicts",
                explanation: "This saying advises neutrality during times of civil unrest. Just as a young camel is not yet useful for riding or milking, one should not be of use to either side in a conflict that divides the community. This promotes peace and prevents fueling division.",
                category: .wisdom,
                arabicText: "كُنْ فِي الْفِتْنَةِ كَابْنِ اللَّبُونِ لَا ظَهْرٌ فَيُرْكَبَ وَلَا ضَرْعٌ فَيُحْلَبَ"
            ),
            Saying(
                number: 2,
                text: "He who adopts greed as a habit devalues himself; he who discloses his hardship agrees to humiliation; and he who allows his tongue to overpower his soul debases the soul.",
                topic: "On greed, complaints, and speech",
                explanation: "This profound saying warns against three character flaws: greed diminishes one's dignity, constantly complaining about difficulties invites humiliation, and letting the tongue speak without restraint degrades one's spiritual essence.",
                category: .character,
                arabicText: nil
            ),
            Saying(
                number: 3,
                text: "Miserliness is the companion of poverty; cowardice is the companion of destitution; and poverty often deprives an intelligent man of his argument.",
                topic: "On poverty and its effects",
                explanation: "This saying explores the relationship between material and spiritual poverty. Miserliness leads to poverty of spirit, cowardice to moral bankruptcy, and material poverty can prevent even the wisest from being heard.",
                category: .worldly,
                arabicText: nil
            ),
            Saying(
                number: 4,
                text: "One who fights for a cause not his own is not intelligent.",
                topic: "On choosing battles wisely",
                explanation: "This teaches discernment in conflict. Fighting for causes that don't align with one's principles or that don't genuinely concern one's welfare or values demonstrates a lack of wisdom.",
                category: .wisdom,
                arabicText: nil
            ),
            Saying(
                number: 5,
                text: "Knowledge is better than wealth. Knowledge guards you, while you have to guard wealth. Wealth decreases by spending, while knowledge multiplies by spending.",
                topic: "The superiority of knowledge over wealth",
                explanation: "This famous saying establishes the supremacy of knowledge over material wealth. Knowledge protects its possessor from ignorance and error, while wealth requires constant protection. When shared, knowledge grows while wealth diminishes.",
                category: .knowledge,
                arabicText: "الْعِلْمُ خَيْرٌ مِنَ الْمَالِ، الْعِلْمُ يَحْرُسُكَ وَأَنْتَ تَحْرُسُ الْمَالَ"
            ),
            Saying(
                number: 6,
                text: "Patience is of two kinds: patience over what pains you, and patience against what you covet.",
                topic: "The two types of patience",
                explanation: "This distinguishes between enduring hardship (patience in adversity) and resisting temptation (patience in prosperity). Both forms of patience are essential for spiritual development.",
                category: .patience,
                arabicText: "الصَّبْرُ صَبْرَانِ: صَبْرٌ عَلَى مَا تَكْرَهُ، وَصَبْرٌ عَمَّا تُحِبُّ"
            ),
            Saying(
                number: 7,
                text: "The tongue is a beast; if it is let loose, it devours.",
                topic: "On controlling speech",
                explanation: "This metaphor warns about the destructive power of uncontrolled speech. Like a wild beast, the tongue can cause immense harm if not properly restrained through wisdom and self-control.",
                category: .morality,
                arabicText: nil
            ),
            Saying(
                number: 8,
                text: "Woman is a scorpion whose grip is sweet.",
                topic: "On temptation and desire",
                explanation: "This metaphorical saying warns about the dual nature of temptation - it may seem pleasant initially but can lead to harmful consequences if one is not careful and mindful.",
                category: .worldly,
                arabicText: nil
            ),
            Saying(
                number: 9,
                text: "If you are greeted, return the greetings more warmly. If you are favored, return the favor manifold; but he who takes the initiative will always excel in merit.",
                topic: "On reciprocating goodness",
                explanation: "This teaches the ethics of social interaction: respond to kindness with greater kindness, but recognize that initiating good deeds holds the highest merit.",
                category: .morality,
                arabicText: nil
            ),
            Saying(
                number: 10,
                text: "The worth of every man is in his attainments.",
                topic: "On human worth and achievement",
                explanation: "This saying emphasizes that a person's true value lies not in lineage, wealth, or status, but in what they have learned, accomplished, and contributed to society.",
                category: .knowledge,
                arabicText: "قِيمَةُ كُلِّ امْرِئٍ مَا يُحْسِنُهُ"
            ),
            Saying(
                number: 11,
                text: "I wonder at the man who loses hope of salvation when the door of repentance is open for him.",
                topic: "On hope and repentance",
                explanation: "This expresses amazement at those who despair when God's mercy is always available through sincere repentance. It encourages maintaining hope even after mistakes.",
                category: .faith,
                arabicText: nil
            ),
            Saying(
                number: 12,
                text: "Generosity is that which is by one's own initiative, because giving on request is either out of self-respect or to avoid rebuke.",
                topic: "True generosity",
                explanation: "Real generosity comes from the heart without being asked. When one gives only upon request, it may be motivated by shame or fear of criticism rather than genuine kindness.",
                category: .character,
                arabicText: nil
            ),
            Saying(
                number: 13,
                text: "There is no wealth like wisdom, no destitution like ignorance, no inheritance like refinement, and no support like consultation.",
                topic: "Four invaluable treasures",
                explanation: "This saying identifies four invaluable assets: wisdom as the greatest wealth, ignorance as the worst poverty, good character as the best inheritance, and consultation as the strongest support.",
                category: .wisdom,
                arabicText: nil
            ),
            Saying(
                number: 14,
                text: "Patience is of two kinds: patience over what pains you, and patience against what you covet.",
                topic: "On types of patience",
                explanation: "This distinguishes between enduring hardship (patience in adversity) and resisting temptation (patience against desires). Both require strength and self-control.",
                category: .patience,
                arabicText: nil
            ),
            Saying(
                number: 15,
                text: "Wealth converts a strange land into homeland and poverty turns a native place into a strange land.",
                topic: "The effect of wealth and poverty",
                explanation: "This observation on human nature shows how material conditions affect one's sense of belonging. Wealth can make one feel at home anywhere, while poverty can alienate one from their birthplace.",
                category: .worldly,
                arabicText: nil
            ),
            Saying(
                number: 16,
                text: "Contentment is the capital which will never diminish.",
                topic: "The value of contentment",
                explanation: "Contentment with what one has is described as an inexhaustible treasure. Unlike material wealth, satisfaction and gratitude provide lasting richness that cannot be depleted.",
                category: .character,
                arabicText: "الْقَنَاعَةُ مَالٌ لَا يَنْفَدُ"
            ),
            Saying(
                number: 17,
                text: "Every breath you take is a step towards death.",
                topic: "On mortality and time",
                explanation: "This stark reminder of mortality encourages mindfulness about the finite nature of life. Each moment brings us closer to our end, making every breath precious.",
                category: .wisdom,
                arabicText: nil
            ),
            Saying(
                number: 18,
                text: "The sin which makes you sad and repentant is more liked by Allah than the good deed which turns you arrogant.",
                topic: "Humility versus arrogance",
                explanation: "This profound spiritual insight shows that sincere repentance after sin is better than acts of worship that lead to pride. Humility is more valuable than corrupted virtue.",
                category: .faith,
                arabicText: nil
            ),
            Saying(
                number: 19,
                text: "The value of a man is according to his courage, his truthfulness is according to his balance of temper, his valour is according to his self-respect, and his chastity is according to his sense of shame.",
                topic: "Measures of character",
                explanation: "This saying provides metrics for evaluating character: courage determines worth, emotional balance indicates honesty, self-respect drives valor, and shame protects chastity.",
                category: .character,
                arabicText: nil
            ),
            Saying(
                number: 20,
                text: "Success is the result of foresight and resolution, foresight depends upon deep thinking and planning, and the most important factor of planning is to keep your secrets to yourself.",
                topic: "The path to success",
                explanation: "This outlines a strategic approach to success: it requires vision and determination, which come from careful thought and planning, and discretion is essential to effective planning.",
                category: .wisdom,
                arabicText: nil
            ),
            Saying(
                number: 21,
                text: "Be afraid of the sin which you commit in solitude, when the witness is also the judge.",
                topic: "On private sins",
                explanation: "This warns about sins committed in privacy, reminding that God is both witness and judge. Private conduct reveals true character more than public behavior.",
                category: .faith,
                arabicText: nil
            ),
            Saying(
                number: 22,
                text: "The one who has no control over his desires has no control over his mind.",
                topic: "Self-control and wisdom",
                explanation: "This establishes the link between controlling desires and mental clarity. Without mastery over wants and impulses, one cannot achieve true wisdom or sound judgment.",
                category: .character,
                arabicText: nil
            ),
            Saying(
                number: 23,
                text: "Meet people in such a manner that if you die, they should weep for you, and if you live, they should long for you.",
                topic: "On treating people well",
                explanation: "This beautiful advice on human relations suggests living with such kindness and value that your absence would be mourned and your presence cherished.",
                category: .morality,
                arabicText: nil
            ),
            Saying(
                number: 24,
                text: "When you gain power over your adversary, pardon him by way of thanks for being able to overpower him.",
                topic: "Mercy in victory",
                explanation: "This noble principle advocates showing mercy when victorious as gratitude for success. True strength is demonstrated through forgiveness, not revenge.",
                category: .justice,
                arabicText: nil
            ),
            Saying(
                number: 25,
                text: "The most helpless of all men is he who cannot find a few brothers during his life, and still more helpless is he who finds such brothers but loses them.",
                topic: "The value of friendship",
                explanation: "This highlights the importance of genuine friendships. Those unable to make true friends are pitiful, but even more tragic is losing friends through one's own actions.",
                category: .morality,
                arabicText: nil
            )
        ]
    }
}
