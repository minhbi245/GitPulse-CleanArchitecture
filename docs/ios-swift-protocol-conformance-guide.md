# iOS Swift Protocol Conformance Guide

Ghi chú kiến thức về Equatable, Hashable, Identifiable trong Swift — khi nào dùng, vì sao cần.

## 1. Equatable — "2 instance có giống nhau không?"

```swift
struct UserDetailsModel: Equatable {
    let username: String
    let followers: Int
}
```

- Compiler tự generate `==` khi tất cả properties đều `Equatable`
- `lhs` (left-hand side) và `rhs` (right-hand side) là convention đặt tên 2 vế của `==`
- Dùng cho: Combine `.removeDuplicates()`, unit test `XCTAssertEqual()`

```swift
// Compiler tự tạo:
static func == (lhs: UserDetailsModel, rhs: UserDetailsModel) -> Bool {
    return lhs.username == rhs.username && lhs.followers == rhs.followers
}

// removeDuplicates() gọi == bên trong:
// previous == current → true → bỏ qua, false → phát ra downstream
```

## 2. Hashable — "Item ở đâu trong hash table?"

```swift
struct UserModel: Hashable {
    let id: Int
    let username: String
}
```

- `Hashable` kế thừa `Equatable` → conform Hashable = có Equatable miễn phí
- Cần cho `DiffableDataSource`, `Set`, `Dictionary`
- Compiler tự generate `hash(into:)` cho struct

## 3. Identifiable — "Item này là ai?"

```swift
struct UserModel: Identifiable {
    let id: Int  // ← property này thỏa mãn protocol
}
```

- Yêu cầu property `id`
- List UI dùng để xác định danh tính item khi list thay đổi (thêm/xóa/reorder)

## 4. Khi nào dùng protocol nào?

| Protocol | Trả lời câu hỏi | Dùng khi |
|----------|-----------------|----------|
| `Equatable` | "Giống nhau không?" | So sánh state, `.removeDuplicates()`, unit test |
| `Hashable` | "Ở đâu trong hash table?" | `DiffableDataSource`, `Set`, `Dictionary` |
| `Identifiable` | "Item này là ai?" | List UI cần xác định danh tính |

## 5. DiffableDataSource vs reloadData

### Cách cũ — `reloadData()`
- Xóa sạch, vẽ lại toàn bộ → nhấp nháy, không animation, tốn performance
- Muốn animation phải tự tính index → rất dễ crash

### Cách mới — `DiffableDataSource`
- Đưa list mới, framework **tự tính diff** (sự khác biệt) và **tự animate**
- Diff = so sánh list cũ vs mới → tính ra item nào thêm/xóa/di chuyển

```swift
var snapshot = NSDiffableDataSourceSnapshot<Section, UserModel>()
snapshot.appendItems(newUsers)
dataSource.apply(snapshot, animatingDifferences: true)
// Tự tính diff, tự animate, không crash
```

