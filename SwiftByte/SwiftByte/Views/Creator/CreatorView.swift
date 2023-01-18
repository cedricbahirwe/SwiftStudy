//
//  CreatorView.swift
//  SwiftByte
//
//  Created by Cédric Bahirwe on 21/12/2022.
//

import SwiftUI

struct CreatorView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var articleVM = ArticlesViewModel()
    @State private var art = SBArticle.empty
    @State private var intro = SBArticleContent(body: "")
    @State private var editedAuthor: SBAuthor?
    @State private var currentStep: SubmissionStep = .author

    enum SubmissionStep: Int, CaseIterable {
        case author, intro, section, keywords, links
        mutating func next() {
            self = .init(rawValue: rawValue+1) ?? Self.allCases.first!
        }
        mutating func previous() {
            self = .init(rawValue: rawValue-1) ?? Self.allCases.last!
        }
    }

    var currentUser: SBUser? {
        authViewModel.getCurrentUser()
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    switch currentStep {
                    case .author:
                        AuthorEditor(firstName: currentUser?.firstName ?? "",
                                     lastName: currentUser?.lastName ?? "",
                                     email: currentUser?.email ?? "") {
                            self.editedAuthor = $0
                            self.currentStep.next()
                        }
//                        AuthorEditor(author: $editedAuthor) {
//                            self.editedAuthor = $0
//                            self.currentStep.next()
//                        }
                    case .intro:
                        TitleAndIntro(title: $art.title,
                                      intro: $intro)
                    case .keywords:
                        KeywordsView(art: $art)
                    case .section:
                        SectionsView(art: $art)
                    case .links:
                        LinksView(art: $art)
                    }
                }
            }

            bottomBarView
        }
        .padding(.horizontal)
        .background(
            Color(.systemBackground)
                .ignoresSafeArea()
                .onTapGesture(perform: hideKeyboard)
        )
        .tint(.blue)
    }

    private func submit() {
        guard !art.title.isEmpty else { return }
        guard !art.content.isEmpty else { return }

        art.author = editedAuthor
        art.intro = intro
        art.createdDate = Date()
        art.updateDate = nil

        Task {
            let articleSaved = await articleVM.addNewArticle(art)
            if articleSaved == false {
                printf("Bad Submission")
            } else {
                prints("Great Submission")
                art = SBArticle.empty
            }
        }
    }
}

private extension CreatorView {
    var bottomBarView: some View {
        HStack {
            LButton("<") {
                withAnimation {
                    currentStep.previous()
                }
            }.frame(width: 50)
            LButton("Submit", action: submit)
            LButton(">") {
                withAnimation {
                    currentStep.next()
                }
            }.frame(width: 50)
        }
    }
}

struct CreatorView_Previews: PreviewProvider {
    static var previews: some View {
        CreatorView()
    }
}

extension View {
    func applyField() -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 10)
                .fill(.red)
                .frame(width: 2)
            self
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(10)
        .background(Color.lightShadow)
        .cornerRadius(10)

    }
}
