//
//  AboutView.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import SwiftUI

struct AboutView: View {
    @EnvironmentObject private var languageService: LanguageService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Purple Header Section
                VStack(spacing: 16) {
                    HStack {
                        Spacer()
                        Button("✕") {
                            dismiss()
                        }
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 12) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 48))
                            .foregroundColor(.white)
                        
                        Text(languageService.isJapanese ? "Mementoについて" : "About Memento")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(languageService.isJapanese ? "アメリカ英語のイディオムをマスター" : "Master American English idioms")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [.purple, .purple.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                    
                // White Content Section
                ScrollView {
                    VStack(spacing: 24) {
                        // What is Memento Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text(languageService.isJapanese ? "定義" : "Definition")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            
                            Text(languageService.isJapanese ? 
                                 "Mementoは、すべての言語習熟度レベルで機能する言語学習アプリです。個人的で適応的、包括的であり、学習者を従来の硬直した学習システムから解放します。" :
                                 "Memento is a language learning app that works across all levels of language proficiency. It is personal, adaptive, and comprehensive, freeing learners from traditional, rigid learning systems.")
                                .font(.body)
                                .lineSpacing(4)
                            
                            Text(languageService.isJapanese ? 
                                 "孤立した語彙や文法練習だけでは言語を完全に学ぶことはできませんが、文化的なニュアンスや現実世界の文脈に対処しなければ、言語をマスターすることはできません。Mementoで学ぶことは、両方の真実を受け入れることを意味します：より深い文化的文脈を理解しながら、言語使用のあらゆる側面にわたる深く、変革的な学習を促進することです。" :
                                 "We cannot fully learn a language through isolated vocabulary and grammar exercises, yet language cannot be mastered without addressing the cultural nuances and real-world contexts that make communication meaningful. Learning with Memento means embracing both truths: working to understand the deeper cultural context while fostering deep, transformative learning that spans every aspect of language use.")
                                .font(.body)
                                .lineSpacing(4)
                            
                            Text(languageService.isJapanese ? 
                                 "Mementoは言語習得のすべての部分を横断する学習です。それは個人的、文化的、実用的なレベルで起こります。内なる意味と外なる表現、そして効果的なコミュニケーションを構成するすべての層とニュアンスを体系的に学ぶことです。" :
                                 "Memento is learning that crosses all the parts of language acquisition. It happens on a personal, cultural, and practical level. It is about systematically learning the inner meaning and the outer expression, and all the layers and nuances that make up effective communication.")
                                .font(.body)
                                .lineSpacing(4)
                            
                            Text(languageService.isJapanese ? 
                                 "Mementoは、文化的理解を核心とした包括的な学習アプローチです：学習者がイディオムをマスターし、言語の障壁を根絶し、私たち全員がより良くコミュニケーションできるよう支援します。" :
                                 "Memento is a holistic learning approach with cultural understanding at the core: helping learners master idioms, eradicating language barriers, and helping us all communicate better together.")
                                .font(.body)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal)
                    
                        // What we do Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text(languageService.isJapanese ? "私たちのアプローチ" : "Our Approach")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        
                        Text(languageService.isJapanese ? 
                             "私たちは言語の障壁が組み込まれた世界を受け継ぎました。私たち全員が積極的に協力して、それらの障壁とそれに伴うコミュニケーションの制限から自分たちを解放する責任があります。私たちは本物の言語使用をインスピレーションと学習の場として見つめ、言語と文化の交差点で個人の学習をサポートする革新的で効果的なアプローチを探求しています。" :
                             "We inherited a world with language barriers built in. It falls on all of us to actively work together to free ourselves from those barriers and the communication limitations that came with them. We look to authentic language use as a place of inspiration and learning, while exploring innovative, effective approaches that support individual learning across the intersections of language and culture.")
                            .font(.body)
                            .lineSpacing(4)
                        
                        Text(languageService.isJapanese ? 
                             "言語教育、文化研究、学習実践における私たちのグローバルな専門知識から、革新的な言語学習プログラムと理論的知識と実践的コミュニケーションの間のギャップを埋める適応的アプローチを構築しました。Mementoモデルを使用することで、これらのプログラムは学習者とコミュニティ内の文化的理解を育み、違いを超えた統一、調和、効果的なコミュニケーションへの道を開きます。" :
                             "Drawing from our global expertise in language education, cultural studies, and learning practices, we have crafted innovative language learning programs and an adaptive approach that bridge the gap between theoretical knowledge and practical communication. Through the use of our Memento Model, these programs nurture cultural understanding within learners and communities, paving the way for unity, harmony, and effective communication across differences.")
                            .font(.body)
                            .lineSpacing(4)
                        
                        Text(languageService.isJapanese ? 
                             "先見の明のある言語教育者がかつて言ったように：'学習はつながりの行為です。'この知恵に触発され、私たちはすべての活動でつながりとコラボレーションを中心に据え、学習と文化的理解が共に繁栄できる空間を作り出しています。これが私たちがコミュニティである理由です。私たちは人々を集め、開発者、教育者、学習者がすべて一つのコミュニティとして集まり、自分自身、コミュニティ、社会のために言語習得という同じ目標に向かって取り組んでいます。" :
                             "As the visionary language educator once said: 'Learning is an act of connection.' Inspired by this wisdom, we center connection and collaboration in all that we do, creating spaces where learning and cultural understanding can thrive together. This is why we are a community, we bring people together, developers, educators and learners all come together as one community working towards the same goal of language mastery for ourselves, for our communities and for society.")
                            .font(.body)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal)
                    
                        // Our Philosophy Section
                        VStack(alignment: .leading, spacing: 24) {
                            Text(languageService.isJapanese ? "私たちの哲学" : "Our Philosophy")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            
                            VStack(alignment: .leading, spacing: 16) {
                                Text(languageService.isJapanese ? "私たちの使命" : "Our Mission")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            
                            Text(languageService.isJapanese ? 
                                 "ツール、戦略、教育を共有することで、私たちは本物のコミュニケーションと再びつながることによって言語習得を通じて人々と学習者を導き、私たちを阻む言語の障壁から私たち全員を統一し、解放します。" :
                                 "By sharing tools, strategies and education, we lead people and learners through language acquisition by reconnecting with authentic communication, to unite and free us all from the language barriers that hold us back.")
                                .font(.body)
                                .lineSpacing(4)
                        }
                        
                            VStack(alignment: .leading, spacing: 16) {
                                Text(languageService.isJapanese ? "私たちの価値観" : "Our Values")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            
                            Text(languageService.isJapanese ? 
                                 "親切さ、思いやり、共感、革新、継続的な学習、そして言語教育の推進。" :
                                 "Kindness, compassion, empathy, innovation, continuous learning and advancing language education.")
                                .font(.body)
                                .lineSpacing(4)
                            
                            Text(languageService.isJapanese ? 
                                 "これらは私たちにとって単なる言葉ではありません。これらは私たち自身の変化の種です。" :
                                 "These aren't just words to us, they're our own seeds for change.")
                                .font(.body)
                                .italic()
                                .foregroundColor(.secondary)
                        }
                        
                        Text(languageService.isJapanese ? 
                             "私たちと一緒に言語学習を体験しましょう。" :
                             "Join us and let's experience language learning together.")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    
                        // Footer
                        VStack(spacing: 8) {
                            Text("© 2025, Memento. All Rights Reserved.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("support@infinitytrigger.com")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
                .padding(.top)
            }
        }
        .navigationBarHidden(true)
        }
    }

#Preview {
    AboutView()
        .environmentObject(LanguageService())
} 
