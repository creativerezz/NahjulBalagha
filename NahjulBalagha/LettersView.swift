import SwiftUI

// MARK: - Data Models

struct Letter: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let recipient: String
    let topic: String
    let excerpt: String
    let content: String
    let category: LetterCategory
    let date: String?
}

enum LetterCategory: String, CaseIterable {
    case governance = "Governance"
    case military = "Military"
    case personal = "Personal"
    case instruction = "Instruction"
    case advice = "Advice"
    case rebuke = "Rebuke"
}

// MARK: - Main View

struct LettersView: View {
    @State private var searchText = ""
    @State private var selectedCategory: LetterCategory? = nil
    @State private var selectedLetter: Letter? = nil
    
    private let letters: [Letter] = sampleLetters
    
    private var filteredLetters: [Letter] {
        var filtered = letters
        
        // Filter by category if selected
        if let selectedCategory = selectedCategory {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { letter in
                letter.title.localizedCaseInsensitiveContains(searchText) ||
                letter.recipient.localizedCaseInsensitiveContains(searchText) ||
                letter.topic.localizedCaseInsensitiveContains(searchText) ||
                letter.excerpt.localizedCaseInsensitiveContains(searchText) ||
                letter.category.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryChip(
                            title: "All",
                            isSelected: selectedCategory == nil,
                            action: { selectedCategory = nil }
                        )
                        
                        ForEach(LetterCategory.allCases, id: \.self) { category in
                            CategoryChip(
                                title: category.rawValue,
                                isSelected: selectedCategory == category,
                                action: {
                                    selectedCategory = selectedCategory == category ? nil : category
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 8)
                .background(AppColors.background)
                
                // Letters List
                if filteredLetters.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "envelope.open")
                            .font(.system(size: 48))
                            .foregroundStyle(AppColors.mutedForeground)
                        Text("No letters found")
                            .font(.headline)
                            .foregroundStyle(AppColors.mutedForeground)
                        Text("Try adjusting your search or filters")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.mutedForeground)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppColors.background)
                } else {
                    List(filteredLetters) { letter in
                        LetterRow(letter: letter) {
                            selectedLetter = letter
                        }
                        .listRowBackground(AppColors.background)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                    .listStyle(.plain)
                    .searchable(text: $searchText, prompt: "Search letters...")
                }
            }
        }
        .navigationTitle("Letters")
        .navigationBarTitleDisplayMode(.large)
        .background(AppColors.background)
        .sheet(item: $selectedLetter) { letter in
            LetterDetailView(letter: letter)
        }
    }
}

// MARK: - Letter Row

struct LetterRow: View {
    let letter: Letter
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Letter \(letter.number)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppColors.primary)
                        
                        Text(letter.title)
                            .font(.headline)
                            .foregroundStyle(AppColors.cardForeground)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    // Category Badge
                    Text(letter.category.rawValue)
                        .font(.caption2.weight(.medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(categoryColor(for: letter.category).opacity(0.15))
                        )
                        .foregroundStyle(categoryColor(for: letter.category))
                }
                
                // Recipient
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.caption2)
                    Text(letter.recipient)
                        .font(.subheadline.weight(.medium))
                }
                .foregroundStyle(AppColors.secondary)
                
                // Topic
                Text(letter.topic)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.mutedForeground)
                    .italic()
                
                // Excerpt
                Text(letter.excerpt)
                    .font(.body)
                    .foregroundStyle(AppColors.foreground)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
    
    private func categoryColor(for category: LetterCategory) -> Color {
        switch category {
        case .governance:
            return AppColors.primary
        case .military:
            return AppColors.destructive
        case .personal:
            return AppColors.chart3
        case .instruction:
            return AppColors.secondary
        case .advice:
            return AppColors.chart1
        case .rebuke:
            return AppColors.chart2
        }
    }
}

// MARK: - Letter Detail View

struct LetterDetailView: View {
    let letter: Letter
    @Environment(\.dismiss) private var dismiss
    @State private var fontSize: Double = 16
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Letter \(letter.number)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppColors.primary)
                            
                            Spacer()
                            
                            Text(letter.category.rawValue)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(categoryColor(for: letter.category).opacity(0.15))
                                )
                                .foregroundStyle(categoryColor(for: letter.category))
                        }
                        
                        Text(letter.title)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(AppColors.cardForeground)
                        
                        // Recipient Card
                        HStack(spacing: 12) {
                            Image(systemName: "person.fill")
                                .font(.title3)
                                .foregroundStyle(AppColors.secondary)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("To")
                                    .font(.caption)
                                    .foregroundStyle(AppColors.mutedForeground)
                                Text(letter.recipient)
                                    .font(.headline)
                                    .foregroundStyle(AppColors.cardForeground)
                            }
                            
                            Spacer()
                            
                            if let date = letter.date {
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Date")
                                        .font(.caption)
                                        .foregroundStyle(AppColors.mutedForeground)
                                    Text(date)
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(AppColors.cardForeground)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(AppColors.muted)
                        )
                        
                        Text(letter.topic)
                            .font(.subheadline)
                            .foregroundStyle(AppColors.mutedForeground)
                            .italic()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    
                    Divider()
                        .padding(.horizontal, 20)
                    
                    // Content
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Key Passage")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(AppColors.cardForeground)
                            
                            Text(letter.excerpt)
                                .font(.system(size: fontSize, weight: .medium, design: .serif))
                                .foregroundStyle(AppColors.primary)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(AppColors.primary.opacity(0.05))
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Full Letter")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(AppColors.cardForeground)
                            
                            Text(letter.content)
                                .font(.system(size: fontSize, design: .serif))
                                .foregroundStyle(AppColors.foreground)
                                .lineSpacing(6)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
            }
            .background(AppColors.background)
            .navigationTitle("Letter Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    ShareLink(item: "\(letter.title)\n\n\(letter.excerpt)\n\n- Letter \(letter.number) to \(letter.recipient)") {
                        Image(systemName: "square.and.arrow.up")
                    }
                    
                    Menu {
                        Section("Font Size") {
                            Button("Small") { withAnimation { fontSize = 14 } }
                            Button("Medium") { withAnimation { fontSize = 16 } }
                            Button("Large") { withAnimation { fontSize = 18 } }
                            Button("Extra Large") { withAnimation { fontSize = 20 } }
                        }
                    } label: {
                        Image(systemName: "textformat.size")
                    }
                }
            }
        }
    }
    
    private func categoryColor(for category: LetterCategory) -> Color {
        switch category {
        case .governance:
            return AppColors.primary
        case .military:
            return AppColors.destructive
        case .personal:
            return AppColors.chart3
        case .instruction:
            return AppColors.secondary
        case .advice:
            return AppColors.chart1
        case .rebuke:
            return AppColors.chart2
        }
    }
}

// MARK: - Sample Data

private let sampleLetters: [Letter] = [
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

#Preview {
    NavigationStack {
        LettersView()
            .background(AppColors.background)
    }
}
