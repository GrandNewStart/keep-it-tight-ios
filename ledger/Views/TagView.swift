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
                guard !newTag.isEmpty else { return }
                tags.append(newTag)
                TagManager.tags = tags
                newTag = ""
            }
            Button("취소", role: .cancel) {
                newTag = ""
            }
        }
    }
}
