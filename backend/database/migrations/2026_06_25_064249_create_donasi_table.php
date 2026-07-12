<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('donasi', function (Blueprint $table) {

            $table->uuid('id')->primary();

            $table->foreignUuid('orangtua_id')
                ->constrained('orangtua')
                ->cascadeOnDelete();

            $table->bigInteger('nominal');

            $table->string('status')
                ->default('pending');

            $table->string('order_id')
                ->unique();

            $table->string('transaction_id')
                ->nullable();

            $table->string('payment_method')
                ->nullable();

            $table->timestamp('paid_at')
                ->nullable();

            $table->timestamps();

        });
    }

    public function down(): void
    {
        Schema::dropIfExists('donasi');
    }
};