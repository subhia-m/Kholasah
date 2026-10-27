// MARK: - شرح الملف
// عنصر زخرفي بصري ضمن لوحة المهام.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

struct BoardDateDecoration: View {
    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        Image("logo")
            .resizable()
            .scaledToFit()
    }
}
