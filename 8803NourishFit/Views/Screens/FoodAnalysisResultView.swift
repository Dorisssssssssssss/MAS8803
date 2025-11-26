import SwiftUI

// MARK: - Food Analysis Result View
struct FoodAnalysisResultView: View {
    @Environment(\.dismiss) private var dismiss
    let selectedImage: UIImage
    @ObservedObject var viewModel: AppViewModel
    
    // TODO: Replace with actual data from backend
    @State private var analysisResult = FoodAnalysisData(
        foodName: "Tonkotsu Ramen",
        matchPercentage: 89,
        servingSize: "230g (1 serving)",
        totalCalories: 900,
        calories: 900,
        protein: 30,
        carbs: 70,
        fat: 70,
        ingredients: [
            IngredientData(name: "Egg", amount: "100g", calories: 50),
            IngredientData(name: "Noodle", amount: "200g", calories: 239),
            IngredientData(name: "Chashu pork", amount: "50g", calories: 85),
            IngredientData(name: "Green Onion", amount: "3g", calories: 1),
            IngredientData(name: "Soup", amount: "600g", calories: 1200)
        ],
        fiber: 2,
        sugar: 2,
        nutritionalInsight: "This meal provides a good balance of macronutrients. Consider pairing it with vegetables to increase fiber and vitamins."
    )
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            ScrollView {
                VStack(spacing: 16) {
                    // Title and Add to Intake Button
                    titleRow
                    
                    // 1. Food Image Card
                    foodImageCard
                    
                    // 2. Nutrition Summary Card
                    nutritionSummaryCard
                    
                    // 3. Detected Foods Card
                    detectedFoodsCard
                    
                    // 4. Nutritional Insights Card
                    nutritionalInsightsCard
                }
                .frame(maxWidth: 359) // Match Figma width
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity) // Center content
            }
            .background(Color.white)
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.primary)
                    .font(.title3)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Title Row
    private var titleRow: some View {
        HStack {
            Text("Result")
                .font(.system(size: 16))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Add to Intake Button
            Button(action: {
                // TODO: Add to intake action
                dismiss()
            }) {
                Text("Add to Intake")
                    .font(.system(size: 13))
                    .foregroundColor(Color(red: 0/255, green: 122/255, blue: 255/255))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color(red: 239/255, green: 246/255, blue: 255/255))
                    .cornerRadius(5)
            }
        }
    }
    
    // MARK: - 1. Food Image Card
    private var foodImageCard: some View {
        Image(uiImage: selectedImage)
            .resizable()
            .scaledToFill()
            .frame(height: 220)
            .clipped()
            .background(Color(red: 243/255, green: 244/255, blue: 246/255))
            .cornerRadius(9.5)
            .padding(15)
            .background(Color.white)
            .cornerRadius(13)
            .overlay(
                RoundedRectangle(cornerRadius: 13)
                    .stroke(Color.black.opacity(0.05), lineWidth: 0.5)
            )
    }
    
    // MARK: - 2. Nutrition Summary Card
    private var nutritionSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with custom gradient icon
            HStack(spacing: 8) {
                // Custom gradient icon (water drop shape similar to SVG)
                Image(systemName: "drop.fill")
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 62/255, green: 129/255, blue: 246/255),  // #3E81F6
                                Color(red: 135/255, green: 93/255, blue: 245/255)   // #875DF5
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .font(.body)
                
                Text("Nutrition Summary")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 62/255, green: 129/255, blue: 246/255),  // #3E81F6
                                Color(red: 135/255, green: 93/255, blue: 245/255)   // #875DF5
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            // Macronutrients Grid (2x2) - Vertical layout for each item
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    // Calories
                    NutritionSummaryItem(label: "Calories", value: "\(analysisResult.calories) kcal")
                    
                    // Protein
                    NutritionSummaryItem(label: "Protein", value: "\(analysisResult.protein)g")
                }
                
                HStack(spacing: 16) {
                    // Carbs
                    NutritionSummaryItem(label: "Carbs", value: "\(analysisResult.carbs)g")
                    
                    // Fat
                    NutritionSummaryItem(label: "Fat", value: "\(analysisResult.fat)g")
                }
            }
        }
        .padding(15)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 239/255, green: 245/255, blue: 255/255),  // #EFF5FF
                    Color(red: 250/255, green: 245/255, blue: 255/255)   // #FAF5FF
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(13)
        .overlay(
            RoundedRectangle(cornerRadius: 13)
                .stroke(Color.black.opacity(0.05), lineWidth: 0.5)
        )
    }
    
    // MARK: - 3. Detected Foods Card
    private var detectedFoodsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Text("Detected Foods")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.bottom, 12)
            
            // Section 1: Main Food Item (Tonkotsu Ramen)
            VStack(alignment: .leading, spacing: 8) {
                // Food name and match percentage
                HStack(alignment: .top) {
                    Text(analysisResult.foodName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                // Match percentage badge with gradient background
                Text("\(analysisResult.matchPercentage)% match")
                    .font(.system(size: 11))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 62/255, green: 129/255, blue: 246/255),  // #3E81F6
                                Color(red: 135/255, green: 93/255, blue: 245/255)   // #875DF5
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 239/255, green: 245/255, blue: 255/255),  // #EFF5FF
                                Color(red: 250/255, green: 245/255, blue: 255/255)   // #FAF5FF
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(4)
                
                // Serving size
                HStack(spacing: 4) {
                    Image(systemName: "scalemass")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(analysisResult.servingSize)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                // Total calories (larger, gradient)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(analysisResult.totalCalories)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 62/255, green: 129/255, blue: 246/255),  // #3E81F6
                                    Color(red: 135/255, green: 93/255, blue: 245/255)   // #875DF5
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("calories")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 12)
            
            // Divider 1
            Rectangle()
                .fill(Color.black.opacity(0.1))
                .frame(height: 0.53)
                .padding(.vertical, 12)
            
            // Section 2: Ingredients List
            VStack(alignment: .leading, spacing: 8) {
                ForEach(analysisResult.ingredients) { ingredient in
                    HStack {
                        Text(ingredient.name)
                            .font(.system(size: 13))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(ingredient.amount)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text("| ")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        +
                        Text("\(ingredient.calories)kcal")
                            .font(.system(size: 12))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 62/255, green: 129/255, blue: 246/255),  // #3E81F6
                                        Color(red: 135/255, green: 93/255, blue: 245/255)   // #875DF5
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }
            }
            .padding(.bottom, 12)
            
            // Divider 2
            Rectangle()
                .fill(Color.black.opacity(0.1))
                .frame(height: 0.53)
                .padding(.vertical, 12)
            
            // Section 3: Additional Nutrients
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Fiber")
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(analysisResult.fiber)g")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Sugar")
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(analysisResult.sugar)g")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(15)
        .background(Color.white)
        .cornerRadius(13)
        .overlay(
            RoundedRectangle(cornerRadius: 13)
                .stroke(Color.black.opacity(0.05), lineWidth: 0.5)
        )
    }
    
    // MARK: - 4. Nutritional Insights Card
    private var nutritionalInsightsCard: some View {
        HStack(alignment: .top, spacing: 10) {
            // Icon
            Image(systemName: "leaf.fill")
                .foregroundColor(Color(red: 21/255, green: 93/255, blue: 252/255))
                .font(.body)
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text("Nutritional Insights")
                    .font(.system(size: 15))
                    .foregroundColor(Color(red: 28/255, green: 57/255, blue: 142/255))
                
                Text(analysisResult.nutritionalInsight)
                    .font(.system(size: 15))
                    .foregroundColor(Color(red: 20/255, green: 71/255, blue: 230/255))
                    .lineLimit(nil)
            }
        }
        .padding(15)
        .background(Color(red: 239/255, green: 246/255, blue: 255/255))
        .cornerRadius(13)
        .overlay(
            RoundedRectangle(cornerRadius: 13)
                .stroke(Color(red: 190/255, green: 219/255, blue: 255/255), lineWidth: 0.5)
        )
    }
}

// MARK: - Nutrition Summary Item Component (Vertical Layout)
struct NutritionSummaryItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Ingredient Data Model
struct IngredientData: Identifiable {
    let id = UUID()
    let name: String
    let amount: String
    let calories: Int
}

// MARK: - Food Analysis Data Model
struct FoodAnalysisData {
    let foodName: String
    let matchPercentage: Int
    let servingSize: String
    let totalCalories: Int
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
    let ingredients: [IngredientData]
    let fiber: Int
    let sugar: Int
    let nutritionalInsight: String
}

// MARK: - Preview
#Preview {
    FoodAnalysisResultView(
        selectedImage: UIImage(systemName: "photo")!,
        viewModel: AppViewModel()
    )
}

