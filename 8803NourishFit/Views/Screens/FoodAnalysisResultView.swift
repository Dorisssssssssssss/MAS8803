import SwiftUI

// MARK: - Food Analysis Result View
struct FoodAnalysisResultView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool // Binding to dismiss the entire flow
    let selectedImage: UIImage
    let mealType: String // Add mealType
    @ObservedObject var viewModel: AppViewModel
    
    // Data from ViewModel
    @State private var analysisResult = FoodAnalysisData(
        foodName: "Loading...",
        matchPercentage: 0,
        servingSize: "--",
        totalCalories: 0,
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        ingredients: [],
        fiber: 0,
        sugar: 0,
        vitaminC: 0,
        nutritionalInsight: "Analyzing..."
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
        .onAppear {
            updateDataFromViewModel()
        }
    }
    
    private func updateDataFromViewModel() {
        guard let analysis = viewModel.currentFoodAnalysis else { return }
        
        let mainFood = analysis.recognizedFoods.first
        let totalCalories = analysis.recognizedFoods.reduce(0) { $0 + $1.calories }
        let totalProtein = analysis.recognizedFoods.reduce(0.0) { $0 + $1.protein }
        let totalCarbs = analysis.recognizedFoods.reduce(0.0) { $0 + $1.carbs }
        let totalFat = analysis.recognizedFoods.reduce(0.0) { $0 + $1.fat }
        let totalFiber = analysis.recognizedFoods.reduce(0.0) { $0 + ($1.fiber ?? 0) }
        let totalSugar = analysis.recognizedFoods.reduce(0.0) { $0 + ($1.sugar ?? 0) }
        let totalVitaminC = analysis.recognizedFoods.reduce(0.0) { $0 + ($1.vitaminC ?? 0) }
        
        let ingredients = analysis.recognizedFoods.map { food in
            IngredientData(
                name: food.name,
                amount: food.weight ?? "1 serving",
                calories: food.calories
            )
        }
        
        analysisResult = FoodAnalysisData(
            foodName: mainFood?.name ?? "Unknown Meal",
            matchPercentage: Int((mainFood?.confidence ?? 0.8) * 100),
            servingSize: mainFood?.weight ?? "1 serving",
            totalCalories: totalCalories,
            calories: totalCalories,
            protein: Int(totalProtein),
            carbs: Int(totalCarbs),
            fat: Int(totalFat),
            ingredients: ingredients,
            fiber: Int(totalFiber),
            sugar: Int(totalSugar),
            vitaminC: Int(totalVitaminC),
            nutritionalInsight: analysis.nutritionalInsight ?? "Good balance of nutrients."
        )
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
            
            // Add to Intake Button (Moved to Header for better accessibility)
            Button(action: {
                // Call confirmMeal to save data
                viewModel.confirmMeal(mealType: mealType)
                
                // Dismiss the entire flow (ScanningView and this view)
                // Setting isPresented to false will dismiss ScanningView, which implicitly dismisses this view
                isPresented = false
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(0.8)
                } else {
                    Text("Add to Intake")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(red: 0/255, green: 122/255, blue: 255/255))
                }
            }
            .disabled(viewModel.isLoading)
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
                
                HStack {
                    Text("Vitamin C")
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(analysisResult.vitaminC)mg")
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
    let vitaminC: Int
    let nutritionalInsight: String
}

// MARK: - Preview
#Preview {
    FoodAnalysisResultView(
        isPresented: .constant(true),
        selectedImage: UIImage(systemName: "photo")!,
        mealType: "Lunch",
        viewModel: AppViewModel()
    )
}

