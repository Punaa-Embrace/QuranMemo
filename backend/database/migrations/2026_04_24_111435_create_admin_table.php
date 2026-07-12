<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('admin', function (Blueprint $table) {
            $table->uuid('id')->primary();

            $table->string('nik')->unique();
            $table->string('email')->unique();
            $table->string('nama');
            $table->string('password');
            $table->text('token')->nullable();

            $table->uuid('role');

            $table->foreign('role')
                ->references('id')
                ->on('role')
                ->cascadeOnUpdate()
                ->restrictOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('admin');
    }
};