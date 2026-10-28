// MARK: - شرح الملف
// يعرض الأصوات في شبكة ويفتح مشغل الصوت المختار مع مشاركة مشغل واحد.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

struct MusicView: View {
    // مشغل الصوت المشترك الذي تنعكس حالته على الواجهة.
    let audioPlayer: FocusAudioPlayer

    // الأصوات المتاحة للاختيار.
    private let sounds = [
        FocusSound(id: "night", title: "Night", assetName: "sandHouse"),
        FocusSound(id: "palms", title: "Palms", assetName: "khobar"),
        FocusSound(id: "rain", title: "Rain", assetName: "car"),
        FocusSound(id: "desert", title: "Desert", assetName: "mountain")
    ]

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // يسمح بتمرير المحتوى عندما يتجاوز المساحة المتاحة.
        ScrollView {
            // شبكة عمودية تنشئ عناصرها عند الحاجة للعرض.
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible())
                ],
                spacing: 18
            ) {
                // ينشئ عنصر واجهة لكل قيمة؛ المعرّف يربط العنصر ببياناته أثناء التحديث.
                ForEach(sounds) { sound in
                    NavigationLink {
                        MusicPlayerView(
                            title: sound.title,
                            artworkName: sound.assetName,
                            audioPlayer: audioPlayer
                        )
                    } label: {
                        FocusSoundCard(
                            title: sound.title,
                            imageName: sound.assetName
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            // يضيف مسافة حول العنصر؛ ترتيب معدلات العرض يؤثر في النتيجة.
            .padding(.horizontal, 32)
            .padding(.vertical, 10)
        }
        .scrollIndicators(.hidden)
    }
}

private struct FocusSound: Identifiable {
    // معرّف يميز هذا العنصر عن بقية العناصر.
    let id: String
    // العنوان المستخدم لهذا العنصر.
    let title: LocalizedStringKey
    // اسم مورد الصورة.
    let assetName: String
}

#Preview {
    NavigationStack {
        MusicView(audioPlayer: FocusAudioPlayer())
    }
}

