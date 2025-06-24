//
//  TagView.swift
//  ledger
//
//  Created by emblock on 6/23/25.
//

import SwiftUI

struct TagView: View {
    @State private var tags: [String] = TagManager.tags.filter({$0 != "태그없음"})
    @State private var newTag: String = ""
    @FocusState private var isNewTagFocused: Bool

    @State private var showDeleteAlert = false
    @State private var tagToDelete: Int?

    @State private var showEditAlert = false
    @State private var tagToEdit: Int?
    @State private var editedTagName: String = ""
    
    @State private var showNewTagAlert = false
    
    @State private var newTagError: String? = nil

    var body: some View {
        VStack {
            List {
                ForEach(tags.indices, id: \.self) { index in
                    Text(tags[index])
                        .swipeActions(edge: .trailing) {
                            Button {
                                tagToDelete = index
                                showDeleteAlert = true
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                            .tint(.red)

                            Button {
                                tagToEdit = index
                                editedTagName = tags[index]
                                showEditAlert = true
                            } label: {
                                Label("수정", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                }
            }
        }
        .onAppear {
            tags = TagManager.tags.filter { $0 != "태그없음" }
        }
        .navigationTitle("태그관리")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showNewTagAlert = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("정말 삭제하시겠습니까?", isPresented: $showDeleteAlert) {
            Button("삭제", role: .destructive) {
                if let index = tagToDelete {
                    tags.remove(at: index)
                    TagManager.tags = tags
                }
                tagToDelete = nil
            }
            Button("취소", role: .cancel) {
                tagToDelete = nil
            }
        }
        .alert("태그 수정", isPresented: $showEditAlert) {
            TextField("수정할 이름", text: $editedTagName)
            Button("저장") {
                if editedTagName.isEmpty {
                    newTagError = "태그 이름을 입력해주세요."
                    return
                }
                if editedTagName.contains(newTag) {
                    newTagError = "이미 존재하는 태그입니다."
                    return
                }
                if editedTagName == "태그없음" {
                    newTagError = "\"태그없음\"은 사용할 수 없습니다."
                    return
                }
                if let index = tagToEdit {
                    tags[index] = editedTagName
                    TagManager.tags = tags
                }
                tagToEdit = nil
                editedTagName = ""
            }
            Button("취소", role: .cancel) {
                tagToEdit = nil
            }
        }
        .alert("새 태그 추가", isPresented: $showNewTagAlert) {
            TextField("태그 이름", text: $newTag)
            Button("추가") {
                if newTag.isEmpty {
                    newTagError = "태그 이름을 입력해주세요."
                    return
                }
                if tags.contains(newTag) {
                    newTagError = "이미 존재하는 태그입니다."
                    return
                }
                if newTag == "태그없음" {
                    newTagError = "\"태그없음\"은 사용할 수 없습니다."
                    return
                }
                tags.append(newTag)
                TagManager.tags = tags
                newTag = ""
            }
            Button("취소", role: .cancel) {
                newTag = ""
            }
        }
        .alert("오류", isPresented: Binding<Bool>(
            get: { newTagError != nil },
            set: { if !$0 { newTagError = nil } }
        )) {
            Button("확인", role: .cancel) { newTagError = nil }
        } message: {
            Text(newTagError ?? "")
        }
    }
}
