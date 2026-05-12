//
//  SkeletonView.swift
//  CareAssistance
//
//  Created on 08/05/2026.
//
//  Skeleton placeholders para reemplazar ProgressView() genéricos.
//  Imitan la forma del contenido real mientras carga.
//
//  Ejemplos de uso:
//
//  1. Skeleton para una card/tile:
//     SkeletonCard()
//
//  2. Skeleton para una lista de items:
//     SkeletonList(rows: 5)
//
//  3. Skeleton personalizado (líneas de texto):
//     SkeletonLines(count: 3)
//
//  4. Skeleton circular (avatar/imagen):
//     SkeletonCircle(size: 60)
//

import SwiftUI

// MARK: - Bloque base

struct SkeletonBlock: View {
    var width: CGFloat? = nil
    var height: CGFloat = 16
    var cornerRadius: CGFloat = 8

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color(.systemGray5))
            .frame(width: width, height: height)
            .shimmer()
    }
}

// MARK: - Círculo (avatar, imagen redonda)

struct SkeletonCircle: View {
    var size: CGFloat = 50

    var body: some View {
        Circle()
            .fill(Color(.systemGray5))
            .frame(width: size, height: size)
            .shimmer()
    }
}

// MARK: - Líneas de texto

struct SkeletonLines: View {
    var count: Int = 3
    var spacing: CGFloat = 10

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(0..<count, id: \.self) { index in
                SkeletonBlock(
                    width: index == count - 1 ? 180 : nil,
                    height: 14
                )
            }
        }
    }
}

// MARK: - Card genérica (imagen + texto)

struct SkeletonCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkeletonBlock(height: 140, cornerRadius: 12)
            SkeletonBlock(width: 200, height: 16)
            SkeletonBlock(width: 140, height: 14)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Fila de lista (icono + texto)

struct SkeletonRow: View {
    var body: some View {
        HStack(spacing: 12) {
            SkeletonCircle(size: 44)
            VStack(alignment: .leading, spacing: 8) {
                SkeletonBlock(width: 160, height: 14)
                SkeletonBlock(width: 100, height: 12)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Lista de filas skeleton

struct SkeletonList: View {
    var rows: Int = 4

    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<rows, id: \.self) { _ in
                SkeletonRow()
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Tile horizontal (para Home dashboard)

struct SkeletonTile: View {
    var body: some View {
        HStack(spacing: 12) {
            SkeletonBlock(width: 60, height: 60, cornerRadius: 12)
            VStack(alignment: .leading, spacing: 8) {
                SkeletonBlock(width: 120, height: 14)
                SkeletonBlock(width: 80, height: 12)
            }
            Spacer()
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}
